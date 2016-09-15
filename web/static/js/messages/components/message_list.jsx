import Message from "./message"

class MessageList extends React.Component {
  render() {
    return (
      <div className="card-cells u-margin-top-1">
        {this.props.messages.map(payload => {
          return <Message key={payload.key} data={payload} />
        })}
      </div>
    )
  }
}

export default MessageList
