package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/mikegleasonjr/workers"
	"io/ioutil"
	"net/http"
	"os"
)

// Example:
// {
//   "subscriber": 9974,
//   "endpoint": "https://eohvjcb59i3mwsu.m.pipedream.net",
//   "id": "82f085b2-3f14-4865-9e70-ab94dea57c68",
//   "params": {
//     "block_number": 16050774,
//     "contract_address_hash": "0x471ece3750da237f93b8e339c536989b8978a438",
//     "log_index": 4,
//     "name": "Transfer",
//     "params": {
//       "from": "0xb460f9ae1fea4f77107146c1960bb1c978118816",
//       "to": "0x045d685d23e8aa34dc408a66fb408f20dc84d785",
//       "value": 0
//     },
//     "topic": "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
//     "transaction_hash": "0x6ccebe5a4edab372473b983ed2b36f48954779fa8768226319a219f8928a8745"
//   }
// }

type Message struct {
	Subscriber string
	Endpoint   string
	Id         string
	Params     map[string]interface{}
}

const UNIMPORTANT = 2048


// TODO:
// - decide what to do with erroneous messages in every case
func main() {
	host := os.Getenv("BEANSTALK_HOST")
	port := os.Getenv("BEANSTALK_PORT")
	tube := os.Getenv("BEANSTALK_TUBE")

	if host == "" {
		host = "127.0.0.1"
	}

	if port == "" {
		port = "11300"
	}

	if tube == "" {
		tube = "processed"
	}

	fmt.Println("Starting")

	mux := workers.NewWorkMux()

	mux.Handle(tube, workers.HandlerFunc(func(job *workers.Job) {
		if !json.Valid(job.Body) {
			fmt.Println("Invalid JSON payload:", job.Body)
			return
		}

		var message Message
		json.Unmarshal([]byte(job.Body), &message)

		payload, err := json.Marshal(message.Params)
		if err != nil {
			fmt.Println("Can't marshall webhook payload", message.Params)
			return
		}

		postBody := bytes.NewBuffer(payload)

		req, err := http.NewRequest("POST", message.Endpoint, postBody)
		if err != nil {
			fmt.Println("Couldn't create HTTP request")
			return
		}

		req.Header.Set("Content-Type", "application/json")

		client := &http.Client{}
		resp, err := client.Do(req)
		if err != nil {
			fmt.Printf("HTTP error: %v", err)
			return
		}

		defer resp.Body.Close()

		if resp.StatusCode > 400 {
			body, err := ioutil.ReadAll(resp.Body)

			if err != nil {
				fmt.Println(err)
				return
			}

			fmt.Println("Posted unsuccessfully, response: ", string(body))
			job.Bury(UNIMPORTANT)
		}

		job.Delete()
	}))

	connection := fmt.Sprintf("%s:%s", host, port)

	workers.ConnectAndWork("tcp", connection, mux)
}
