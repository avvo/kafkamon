class Timestamp extends React.Component {
  pad(number) {
    if (number < 10) {
      return '0' + number
    }
    return number
  }

  formatTimestamp(timestamp) {
    let date = new Date(timestamp * 1000)
    // date.getFullYear() + '-' + this.pad(date.getMonth() + 1) + '-' + this.pad(date.getDate()) + ' ' +
    return this.pad(date.getHours()) +
        ':' + this.pad(date.getMinutes()) +
        ':' + this.pad(date.getSeconds())
  }

  render() {
    return (
      <span><span className="timestamp">{this.formatTimestamp(this.props.timestamp)}</span></span>
    )
  }
}
export default Timestamp
