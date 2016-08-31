// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

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
      activeTopic: "",
      messages: [],
      topicsChannel: socket.channel("topics", {}),
      activeChannel: null,
      currentOffset: null
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
        messages: this.state.messages.concat([message]),
        currentOffset: message.offset
      })
    })
  },
  handleTopicLinkClick(topic) {
    if (this.state.activeChannel) {
      this.state.activeChannel.leave()
        .receive("ok", resp => { console.log(`Left '${this.state.activeChannel.topic}' successfully`, resp) })
    }
    let channel = socket.channel(`topic:${topic}`)
    this.setState({activeTopic: topic, activeChannel: channel, messages: []})
    this.configureChannel(channel)
  },
  render() {
    return(
      <div className="page-container">
        <div className="page-left">
          <TopicList topics={this.state.topics} onTopicLinkClick={this.handleTopicLinkClick}/>
        </div>
        <div className="page-content">
          <Messages topic={this.state.activeTopic} messages={this.state.messages} currentOffset={this.state.currentOffset}/>
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
          return <div key={topic}><TopicLink onClick={this.props.onTopicLinkClick} name={topic} /></div>
        })}
      </div>
    )
  }
})

let TopicLink = React.createClass({
  handleClick() {
    this.props.onClick(this.props.name)
  },
  render() {
    return(
      <a style={{cursor: "pointer"}} onClick={this.handleClick}>{this.props.name}</a>
    )
  }
})

let Messages = React.createClass({
  render() {
    return(
      <div>
        <div>Welcome to the '{this.props.topic}' topic, the current offset is {this.props.currentOffset}</div>
        <MessageList messages={this.props.messages}/>
      </div>
    )
  }
})

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
    let {event, ...message} = this.props.data.message
    return {
      event: event,
      message: message,
    }
  },
  render() {
    return (
      <div className="messageBlock">
        <Event event={this.state.event}/>
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
