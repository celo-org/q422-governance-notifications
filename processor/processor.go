package main

import (
	"encoding/json"
	"fmt"
	beanstalk "github.com/beanstalkd/go-beanstalk"
	"github.com/google/uuid"
	"github.com/mikegleasonjr/workers"
	"gopkg.in/yaml.v3"
	"io/ioutil"
	"log"
	"os"
	"strconv"
	"time"
)

// Example:
// {
// 	"block_number": 16053485,
// 	"contract_address_hash": "0x471ece3750da237f93b8e339c536989b8978a438",
// 	"log_index": 306,
// 	"name": "Transfer",
// 	"params": {
// 			"from": "0xfdb4ae994efe0202f5bee70f2d7641447ffccedc",
// 			"to": "0x94f34205141df231fb860d60c09365ed9fa25259",
// 			"value": 13374269616752466
// 	},
// 	"topic": "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
// 	"transaction_hash": "0x71eea71a3ad01ed58628ca06d81e26ff492c7c5b8ad02302e94099a0dd3d2c68"
// }

const RETRY_LATER = 2048

type SubscriberId = int64

type Subscriber struct {
	Id  SubscriberId
	Url string
}

type Topic struct {
	Topic       string
	Name        string
	Subscribers []Subscriber
}

type Contract struct {
	ContractAddressHash string `yaml:"contract_address_hash"`
	Name                string
	Topics              []Topic
}

type Config struct {
	Contracts []Contract
}

type Event struct {
	BlockNumber         int64                  `json:"block_number"`
	ContractAddressHash string                 `json:"contract_address_hash"`
	LogIndex            int32                  `json:"log_index"`
	Name                string                 `json:"name"`
	Params              map[string]interface{} `json:"params"`
	Topic               string                 `json:"topic"`
	TransactionHash     string                 `json:"transaction_hash"`
}

func (event *Event) asMessageForSubscriber(subscriber *Subscriber) *Message {
	id := uuid.New()

	return &Message{
		Subscriber: strconv.FormatInt(subscriber.Id, 10),
		Endpoint:   subscriber.Url,
		Id:         id,
		Params:     *event,
	}
}

// TODO: share between notifier and processor
type Message struct {
	Subscriber string
	Endpoint   string
	Id         uuid.UUID
	Params     Event
}

type Router struct {
	Subscribers   map[SubscriberId]*Subscriber
	Subscriptions map[string][]SubscriberId
}

func (router *Router) AddSubscription(contract *Contract, topic *Topic, subscriber *Subscriber) {
	// unique subscription id in the %contract_address_hash%.%topic% format
	subscriptionId := router.getSubscriptionId(contract.ContractAddressHash, topic.Topic)

	router.Subscriptions[subscriptionId] = append(router.Subscriptions[subscriptionId], subscriber.Id)
	router.Subscribers[subscriber.Id] = subscriber
}

func (router *Router) getSubscriptionId(contract_address_hash string, topic string) string {
	return fmt.Sprintf("%s.%s", contract_address_hash, topic)
}

func (router *Router) getSubscribers(event *Event) []*Subscriber {
	subscriptionId := router.getSubscriptionId(event.ContractAddressHash, event.Topic)
	subscriberIds := append(router.Subscriptions["*.*"], router.Subscriptions[subscriptionId]...)

	subscribers := []*Subscriber{};

	for _, i := range subscriberIds {
		subscribers = append(subscribers, router.Subscribers[i])
	}

	return subscribers
}

func readConfig(filename string) (*Config, error) {
	log.Printf("Reading config file %s", filename)
	buf, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	c := &Config{}
	err = yaml.Unmarshal(buf, c)
	if err != nil {
		return nil, fmt.Errorf("in file %q: %w", filename, err)
	}

	return c, err
}

func initRouter(filename string) *Router {
	config, err := readConfig(filename)
	if err != nil {
		log.Fatal(err)
	}

	router := Router{
		Subscribers:   make(map[SubscriberId]*Subscriber),
		Subscriptions: make(map[string][]SubscriberId),
	}

	for _, c := range config.Contracts {
		for _, t := range c.Topics {
			for _, s := range t.Subscribers {
				router.AddSubscription(&c, &t, &s)
			}
		}
	}

	return &router
}

func main() {
	host := os.Getenv("BEANSTALK_HOST")
	port := os.Getenv("BEANSTALK_PORT")
	inTube := os.Getenv("BEANSTALK_IN_TUBE")
	outTube := os.Getenv("BEANSTALK_OUT_TUBE")

	if host == "" {
		host = "127.0.0.1"
	}

	if port == "" {
		port = "11300"
	}

	if inTube == "" {
		inTube = "default"
	}

	if outTube == "" {
		outTube = "processed"
	}

	connection := fmt.Sprintf("%s:%s", host, port)

	router := initRouter("conf.yml")

	// we're using a separate connection to enqueue new jobs
	conn, err := beanstalk.Dial("tcp", connection)
	if err != nil {
		log.Fatalf("Can't connect to the queue %s", connection)
	}

	conn.Tube = *beanstalk.NewTube(conn, outTube)

	mux := workers.NewWorkMux()
	mux.Handle(inTube, workers.HandlerFunc(func(job *workers.Job) {
		if !json.Valid(job.Body) {
			fmt.Println("Invalid JSON payload:", job.Body)
			job.Bury(RETRY_LATER)
			return
		}

		var event Event
		err := json.Unmarshal([]byte(job.Body), &event)
		if err != nil {
			fmt.Printf("Can't unmarshal event %v", event)
			job.Bury(RETRY_LATER)
		}

		subscribers := router.getSubscribers(&event)

		if len(subscribers) == 0 {
			// if there are no subscribers, just discard the job
			job.Delete()
			return
		}

		for _, s := range subscribers {
			payload, err := json.Marshal(event.asMessageForSubscriber(s))

			if err != nil {
				log.Fatalf("Cannot create payload, %v", err)
			}

			jobId, err := conn.Put(payload, 1, 0, 120*time.Second)
			if err != nil {
				log.Fatalf("Error queueing the job %v: %e", payload, err)
			}

			log.Printf("Enqueued job %v", jobId)
			job.Delete()
		}
	}))

	workers.ConnectAndWork("tcp", connection, mux)
}
