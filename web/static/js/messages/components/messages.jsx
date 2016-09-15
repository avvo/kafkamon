import MessageList from "./message_list"

class Messages extends React.Component {
  render(){
    return (
      <div>
        {
          this.props.topic ?
          (
            <h2 className="u-margin-top-0">
              Welcome to the '{this.props.topic}' topic, the current offset is {this.props.currentOffset || '0'}
            </h2>
          )
          :
          (
            <h2 className="u-margin-top-0">Select a topic to get started</h2>
          )
        }

        <MessageList messages={this.props.messages}/>
      </div>
    )
  }
}

export default Messages
