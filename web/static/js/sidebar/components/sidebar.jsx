import TopicList from "./topic_list"

class Sidebar extends React.Component {
  render() {
    return (
      <div className="u-margin-bottom-1">
        <TopicList topics={this.props.topics} onTopicLinkClick={this.props.onTopicLinkClick}/>
      </div>
    )
  }
}
export default Sidebar
