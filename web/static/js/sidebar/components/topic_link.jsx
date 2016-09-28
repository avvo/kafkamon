class TopicLink extends React.Component {
  handleClick() {
    this.props.onClick(this.props.name)
  }

  render(){
    return(
      <a style={{cursor: "pointer"}} onClick={() => this.handleClick()}>{this.props.name}</a>
    )
  }
}
export default TopicLink
