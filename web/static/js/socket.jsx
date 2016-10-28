// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"
import React from "react"
import ReactDOM from "react-dom"
import Toggle from "react-toggle"
import Datetime from "react-datetime"
import moment from "moment"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:

let Main = React.createClass({
  getInitialState() {
    return {
      topics: [],
      activeChannels: {},
      messages: [],
      topicsChannel: socket.channel("topics", {}),
    }
  },
  componentDidMount() {
    this.state.topicsChannel.join()
      .receive("ok", resp => { console.log("Joined 'topics' successfully", resp) })
      .receive("error", resp => { console.log("Unable to join 'topics'", resp) })
    this.state.topicsChannel.on("change", payload => {
      this.setState({topics: payload.all})
    })
  },
  configureChannel(channel) {
    channel.join()
      .receive("ok", resp => { console.log(`Joined '${channel.topic}' successfully`, resp) })
      .receive("error", resp => { console.log(`Unable to join '${channel.topic}'`, resp) })

    channel.on("new:message", message => {
      this.setState({
        messages: this.state.messages.concat([message]).slice(-100)
      })
    })

    channel.on("new:messages", data => {
      this.setState({
        messages: this.state.messages.concat(data.messages).slice(-100)
      })
    })
  },
  handleTopicChange(topic, event) {
    if (event.target.checked) {
      let newChannel = {}
      newChannel[topic] = socket.channel(`topic:${topic}`)

      this.setState({
        activeChannels: Object.assign(this.state.activeChannels, newChannel),
      })

      this.configureChannel(newChannel[topic])
    } else if (this.state.activeChannels[topic]) {
      this.state.activeChannels[topic].leave()
        .receive("ok", resp => { console.log(`Left '${topic}' successfully`, resp) })

      let removeChannel = {}
      removeChannel[topic] = undefined

      this.setState({
        activeChannels: Object.assign(this.state.activeChannels, removeChannel),
      })
    }
  },
  handleTimepick(datetime) {
    let topics = Object.keys(this.state.activeChannels)
    let self = this

    if (topics.length > 0 && datetime) {
      let request = new Request(`/messages?topics=${topics.join(",")}&pickedTime=${datetime.format()}`)
      let headers = new Headers()
      headers.append("Accept", "application/json")
      fetch(request, {headers: headers}).then(resp => {
        return resp.json()
      }).then(resp => {
        self.setState({
          messages: resp.messages
        })
      })
    }
  },
  render() {
    return(
      <div className="page-container">
        <div className="page-left">
          <TopicList topics={this.state.topics} onTopicChange={this.handleTopicChange}/>
        </div>
        <div className="page-content">
          <ControlBar onTimepick={this.handleTimepick} />
          <Messages topic={this.state.activeTopic} messages={this.state.messages}/>
        </div>
      </div>
    )
  }
})

let TopicList = React.createClass({
  render() {
    return(
      <div>
        {this.props.topics.map(topic => {
          return <div key={topic}><TopicLink onChange={this.props.onTopicChange} name={topic} /></div>
        })}
      </div>
    )
  }
})

let TopicLink = React.createClass({
  handleChange(event) {
    this.props.onChange(this.props.name, event)
  },
  render() {
    return(
      <label className="topic-label">
        <Toggle onChange={this.handleChange} />
        <span style={{cursor: "pointer"}}>{this.props.name}</span>
      </label>
    )
  }
})

let Messages = React.createClass({
  render() {
    return(
      <div>
        <MessageList messages={this.props.messages}/>
      </div>
    )
  }
})

let ControlBar = React.createClass({
  getInitialState() {
    return {
      timeMode: 'trail',
      pickedTime: null
    }
  },
  handleTimeModeChange(changeEvent) {
    if (this.state.pickedTime === null) {
      this.setState({ pickedTime: moment() })
    }
    this.setState({
      timeMode: changeEvent.target.value
    })
  },
  handleTimePicked(changeEvent) {
    this.setState({
      pickedTime: changeEvent
    })
  },
  handleButtonClicked() {
    console.log("click firing")
    this.props.onTimepick(this.state.pickedTime)
  },
  render () {
    return (
      <div className="controlBar">
        <label><input type="radio" name="timeMode" value="trail" checked={this.state.timeMode === 'trail'} onChange={this.handleTimeModeChange}/>Trail</label>
        <label><input type="radio" name="timeMode" value="pick" checked={this.state.timeMode === 'pick'} onChange={this.handleTimeModeChange}/>Pick</label>
        <Datetime
          value={this.state.pickedTime}
          onChange={this.handleTimePicked}
          />
        <input type="button" onClick={this.handleButtonClicked} value="Go" />
      </div>
    )
  }
})
            /*input={this.state.timeMode === 'pick'}*/

let MessageList = React.createClass({
  render() {
    return (
      <div className="messageList">
        {this.props.messages.map(payload => {
          return <Message key={payload.key} data={payload} />
        })}
      </div>
    )
  }
})

let Message = React.createClass({
  getInitialState() {
    let {event, ...message} = this.props.data.value
    return {
      event: event,
      message: message,
      meta: {
        partition: this.props.data.partition,
        offset: this.props.data.offset,
        topic: this.props.data.topic,
      }
    }
  },
  render() {
    return (
      <div className="messageBlock">
        <Event meta={this.state.meta} event={this.state.event}/>
        <div className="message"> {JSON.stringify(this.state.message)}</div>
      </div>
    )
  }
})

let Event = React.createClass({
  render() {
    return (
      <div className="event">
        <Timestamp timestamp={this.props.event.timestamp}/>
        <span className="key">
          <span className="topic">{this.props.meta.topic}</span>/<span className="partition">{this.props.meta.partition}</span>
          #<span className="offset">{this.props.meta.offset}</span>
        </span>
        <span className="app_id">{this.props.event.app_id}</span>
        <span className="name">{this.props.event.name}</span>
      </div>
    )
  }
})

let Timestamp = React.createClass({
  pad(number) {
    if (number < 10) {
      return '0' + number
    }
    return number
  },
  formatTimestamp(timestamp) {
    let date = new Date(timestamp * 1000)
    // date.getFullYear() + '-' + this.pad(date.getMonth() + 1) + '-' + this.pad(date.getDate()) + ' ' + 
    return this.pad(date.getHours()) +
        ':' + this.pad(date.getMinutes()) +
        ':' + this.pad(date.getSeconds())
  },
  render() {
    return (
      <span><span className="timestamp">{this.formatTimestamp(this.props.timestamp)}</span></span>
    )
  }
})

ReactDOM.render(<Main />, document.getElementById("main"))

export default socket
