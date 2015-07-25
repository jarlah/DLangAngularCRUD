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

/**
 * Retrieve the current Contacts data from the CMStore
 */
function getContactsState() {
  return {
    allContacts: CMStore.getAll(),
    editContact: CMStore.getEditContact()
  };
}

var CMApp = React.createClass({
  getInitialState: function() {
    return getContactsState();
  },
  
  componentDidMount: function() {
	CMStore.on('save', this._onChange);
	CMStore.on('remove', this._onChange);
	CMStore.on('edit', this._onModal);
	CMStore.on('create', this._onChange);
  },
  
  componentWillUnmount: function() {
	CMStore.off('save', this._onChange);
	CMStore.off('remove', this._onChange);
	CMStore.off('edit', this._onModal);
	CMStore.off('create', this._onChange);
  },
  
  render: function() {
    // request to edit a specific contact from store
    var editId = this.state.editContact._id;
    var editContact = this.state.editContact;
    if (editId !== undefined) {
      $('#edit_contact_modal').openModal();

      // fill form elements with selected contact info
      $('#edit_contact_form').find('#contact_id').val(editContact._id);
      $('#edit_contact_form').find('#contact_name').val(editContact.name);
      $('#edit_contact_form').find('#contact_phone').val(editContact.phone);
      $('#edit_contact_form').find('#contact_email').val(editContact.email);
      $('#edit_contact_form').find('#contact_avatar').val(editContact.avatar);

      // focus on the first field with a little delay so it won't mess-
      // with modal focus
      setTimeout(function() {
        $('#edit_contact_form').find('#contact_name').focus();
      },50);
      
      // changing back to undefined so it prevent from opening the modal-
      // everytime the view is rendering
      this.state.editContact._id = undefined;
    }
    // main block
    return(
      <ul className="collection">
        <Navbar/>
        <ContactList data={this.state.allContacts}/>
        <ContactModal />
        <EditContactModal editContact={this.state.editContact} />
      </ul>
    );
  },
  
  _onChange: function() {
    this.setState(getContactsState());
  },
  
  _onModal: function() {
	this.setState({
	    allContacts: this.state.allContacts,
	    editContact: CMStore.getEditContact()
	});
  }
});

module.exports = CMApp;