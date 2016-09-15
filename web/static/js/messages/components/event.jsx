import Timestamp from "./timestamp"

class Event extends React.Component {
  render(){
    return (
      <div className="event">
        <Timestamp timestamp={this.props.event.timestamp}/>
        <span className="u-text-color-electric-blue">&nbsp;{this.props.event.app_id}</span>
        <span className="u-text-color-green">&nbsp;{this.props.event.name}</span>
      </div>
    )
  }
}

export default Event
