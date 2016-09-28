import Event from "./event"

class Message extends React.Component {
  constructor(props){
    super(props)
    let {event, ...message} = this.props.data.message
    this.state = {
      event: event,
      message: message,
    }
  }
  render() {
    return (
      <div className="card-cells">
        <div className="row">
          <div className="card col-xs-12">
            <Event event={this.state.event}/>
            <div className="message"> {JSON.stringify(this.state.message)}</div>
          </div>
        </div>
      </div>
    )
  }
}

export default Message
