var PersonBox = React.createClass({
  loadPersonsFromServer: function() {
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      cache: false,
      success: function(data) {
        this.setState({data: data});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },

  deletePerson: function(id) {
    $.ajax({
      url: this.props.url + '/' + id,
      dataType: 'json',
      type: 'DELETE',
      success: function(data) {
    	 (elem=document.getElementById(id)).parentNode.removeChild(elem);
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
	  
  handlePersonSubmit: function(person) {
    var persons = this.state.data;
    var newPersons = persons.concat([person.person]);
    this.setState({data: newPersons});
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      contentType:"application/json; charset=utf-8",
      type: 'POST',
      data: JSON.stringify(person),
      success: function(data) {
        this.setState({data: data});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },

  getInitialState: function() {
    return {data: []};
  },

  componentDidMount: function() {
    this.loadPersonsFromServer();
    setInterval(this.loadPersonsFromServer, this.props.pollInterval);
  },

  render: function() {
    return (
      <div className="personBox">
        <h1>Persons</h1>
        <PersonForm onPersonSubmit={this.handlePersonSubmit} />  
        <PersonList onDelete={this.deletePerson} data={this.state.data} />
      </div>
    );
  }
});

var PersonList = React.createClass({
  render: function() {
	var props = this.props,
		personNodes = props.data.map(function (person) {
	      return (
			<li className="person" id={person._id}>        
			   <Person {...person} onDelete={props.onDelete} />
			</li>
	      );
	    });
    return (
      <ul className="personList">
        {personNodes}
      </ul>
    );
  }
});

var PersonForm = React.createClass({
  handleSubmit: function(e) {
    e.preventDefault();
    var firstName = React.findDOMNode(this.refs.firstName).value.trim();
    var lastName = React.findDOMNode(this.refs.lastName).value.trim();
    var id = parseInt(React.findDOMNode(this.refs.id).value.trim(), 10);
    if (!firstName || !lastName || !id) {
      return;
    }
    this.props.onPersonSubmit({person: {id: id, firstName: firstName, lastName: lastName}});
    React.findDOMNode(this.refs.firstName).value = '';
    React.findDOMNode(this.refs.lastName).value = '';
    React.findDOMNode(this.refs.id).value = '';
    return;
  },
  
  render: function() {
    return (
     <form className="personForm" onSubmit={this.handleSubmit}>
       <input type="number" placeholder="Id" ref="id" />
       <br />
       <input type="text" placeholder="First name" ref="firstName" />
       <br />
       <input type="text" placeholder="Last name" ref="lastName" />
       <br />
       <input type="submit" value="Post" />
     </form>
   );
  }
});

var Person = React.createClass({
  deleteMe: function() {
	this.props.onDelete(this.props._id);  
  },
  render: function() {
    return (
      <span>
      	{this.props.id}&nbsp;{this.props.firstName}&nbsp;{this.props.lastName}&nbsp;
      	|&nbsp;<a href="javascript:void(0)" onClick={this.deleteMe}>Delete</a>&nbsp;
      	|&nbsp;<a href="javascript:void(0)" onClick={this.editMe}>Edit</a>
      </span>
    );
  }
});

React.render(
  <PersonBox url="api/person" pollInterval={60000} />,
  document.getElementById('content')
);