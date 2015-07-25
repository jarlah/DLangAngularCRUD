var React = require('react');
var Contact = require('./Contact.react');

var ContactList = React.createClass({
	render:function() {
		var contacts = this.props.data.map(function(contact) {
			return <Contact contact={contact} />;
		});
		return(<ul>{contacts}</ul>);
	}
});

module.exports = ContactList;