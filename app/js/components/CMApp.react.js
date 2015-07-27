/**
 * This component operates as a "Controller-View".  It listens for changes in
 * the CMStore and passes the new data to its children.
 */

var React = require('react');
var Navbar = require('./Navbar.react');
var ContactModal = require('./ContactModal.react');
var EditContactModal = require('./EditContactModal.react');
var ContactList = require('./ContactList.react');
var CMStore = require('../stores/CMStore');
var CMActions = require('../actions/CMActions');

var CMApp = React.createClass({
  getInitialState: function() {
    return this._getContactsState();
  },
  
  componentDidMount: function() {
	CMStore.on('change', this._onChange);
	CMStore.on('edit', this._onEdit);
  },
  
  componentWillUnmount: function() {
	CMStore.off('change', this._onChange);
	CMStore.off('edit', this._onEdit);
  },
  
  render: function() {
    var editContact = this.state.editContact;

    if (editContact._id !== undefined) {
      $('#edit_contact_modal').openModal();
      $('#edit_contact_form').find('#contact_id').val(editContact._id);
      $('#edit_contact_form').find('#contact_name').val(editContact.name);
      $('#edit_contact_form').find('#contact_phone').val(editContact.phone);
      $('#edit_contact_form').find('#contact_email').val(editContact.email);
      $('#edit_contact_form').find('#contact_avatar').val(editContact.avatar);
      setTimeout(function() {
        $('#edit_contact_form').find('#contact_name').focus();
      },50);
      
      this.state.editContact._id = undefined;
    }
    
    return(
      <ul className="collection">
        <Navbar/>
        <ContactList data={this.state.allContacts}/>
        <ContactModal />
        <EditContactModal editContact={this.state.editContact} />
      </ul>
    );
  },
  
  _getContactsState: function() {
	return {
		allContacts: CMStore.getAll(),
		editContact: CMStore.getEditContact()
	};
  },
  
  _onChange: function() {
    this.setState(this._getContactsState());
  },
  
  _onEdit: function() {
	this.setState({
	    allContacts: this.state.allContacts,
	    editContact: CMStore.getEditContact()
	});
  }
});

module.exports = CMApp;