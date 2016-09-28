import socket   from "../../messages/helpers/socket"
import Header   from "../../header/components/header"
import Sidebar  from "../../sidebar/components/sidebar"
import Messages from "../../messages/components/messages"

class Kafkamon extends React.Component {

  constructor(props) {
    super(props)
    this.state = {
      topics: [],
      activeTopic: "",
      messages: [],
      topicsChannel: socket.channel("topics", {}),
      activeChannel: null,
      currentOffset: null
    }
  }

  componentDidMount() {
    this.state.topicsChannel.join()
      .receive("ok", resp => { console.log("Joined 'topics' successfully", resp) })
      .receive("error", resp => { console.log("Unable to join 'topics'", resp) })

    this.state.topicsChannel.on("change", payload => {
      this.setState({topics: payload.all})
    })
  }

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
  }

  handleTopicLinkClick(topic) {
    if (this.state.activeChannel) {
      this.state.activeChannel.leave()
        .receive("ok", resp => { console.log(`Left '${this.state.activeChannel.topic}' successfully`, resp) })
    }
    let channel = socket.channel(`topic:${topic}`)
    this.setState({activeTopic: topic, activeChannel: channel, messages: []})
    this.configureChannel(channel)
  }

  render(){
    return (
      <div>
        <Header />
        <div className="container u-vertical-margin-1">
          <div className="row">
            <div className="col-sm-12 col-md-4">
              <Sidebar topics={this.state.topics} onTopicLinkClick={(topic) => this.handleTopicLinkClick(topic)}/>
            </div>
            <div className="col-sm-12 col-md-8">
              <Messages topic={this.state.activeTopic} messages={this.state.messages} currentOffset={this.state.currentOffset}/>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

export default Kafkamon

ReactDOM.render(<Kafkamon />, document.getElementById("main"))
