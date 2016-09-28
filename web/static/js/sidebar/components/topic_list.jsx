import TopicLink from "./topic_link"

class TopicList extends React.Component {
  render(){
    return(
      <div>
        {this.props.topics.map(topic => {
          return <div key={topic}><TopicLink onClick={this.props.onTopicLinkClick} name={topic} /></div>
        })}
      </div>
    )
  }
}
export default TopicList
