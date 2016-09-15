class Header extends React.Component {
  render(){
    return (
      <header className="header">
        <div className="container">
            <div className="header-group">
              <a className="header-brand" href="/">
                <span>
                  <span className="icon icon-avvo"></span>
                  <span className="u-text-color-orange"> Kafkamon</span>
                </span>
              </a>
            </div>
        </div>
      </header>
    )
  }
}

export default Header
