
var AppDispatcher = require('../dispatcher/AppDispatcher');
var EventEmitter = require('events').EventEmitter;
var CMConstants = require('../constants/CMConstants');
var assign = require('object-assign');
var URL = 'api/contact';
var CHANGE_EVENT = 'change';

var _contacts = [];
var _editContact = {};

// will be used to incremental id for contacts
var currentId = 0;

// saving new contact
function create(newContact) {
	delete newContact.actionType;
	$.ajax({
	  url: URL,
	  dataType: 'json',
	  contentType:"application/json; charset=utf-8",
	  type: 'POST',
	  data: JSON.stringify({contact: newContact}),
	  async:false,
	  success: function(data) {
	    // TODO
	  }.bind(this),
	  error: function(xhr, status, err) {
	    console.error(URL, status, err.toString());
	  }.bind(this)
	});
}

// sending edit id to controller view
function edit(contact) {
  _editContact = {
    _id: contact._id,
    name: contact.name,
    phone: contact.phone,
    email: contact.email,
    avatar: contact.avatar
  };
}

// saving edited contact
function save(contact) {
	var id = contact._id;
	delete contact.actionType;
	delete contact._id;
	$.ajax({
	  url: URL + '/' + id,
	  dataType: 'json',
	  contentType:"application/json; charset=utf-8",
	  type: 'PUT',
	  data: JSON.stringify({contact: contact}),
	  async:false,
	  success: function(data) {
	    // TODO
	  }.bind(this),
	  error: function(xhr, status, err) {
	    console.error(URL, status, err.toString());
	  }.bind(this)
	});
}

// removing contact by user
function remove(removeId) {
	$.ajax({
	  url: URL + '/' + removeId,
	  dataType: 'json',
	  contentType:"application/json; charset=utf-8",
	  type: 'DELETE',
	  async:false,
	  success: function(data) {
	    // TODO
	  }.bind(this),
	  error: function(xhr, status, err) {
	    console.error(URL, status, err.toString());
	  }.bind(this)
	});
}


var CMStore = assign({}, EventEmitter.prototype, {
  /**
   * Get the entire Contacts.
   * @return {object}
   */
  getEditContact: function() {
    return _editContact;
  },
  
  getAll: function() {
	var theResponse = null;
    $.ajax({
      url: URL,
      dataType: 'json',
      cache: false,
      async: false,
      success: function(data) {
        theResponse = data;
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(URL, status, err.toString());
      }.bind(this)
    });
    return theResponse;
  },

  emitChange: function() {
    this.emit(CHANGE_EVENT);
  },

  /**
   * @param {function} callback
   */
  addChangeListener: function(callback) {
    this.on(CHANGE_EVENT, callback);
  },

  /**
   * @param {function} callback
   */
  removeChangeListener: function(callback) {
    this.removeListener(CHANGE_EVENT, callback);
  }
});

// Register callback to handle all updates
AppDispatcher.register(function(action) {
  var text;

  switch(action.actionType) {
    case CMConstants.CM_CREATE:
      text = action.name.trim();
      if (text !== '') {
        create(action);
        CMStore.emitChange();
      }
      break;

    case CMConstants.CM_EDIT:
      edit(action);
      CMStore.emitChange();
      break;

    case CMConstants.CM_SAVE:
      save(action);
      CMStore.emitChange();
      break;

    case CMConstants.CM_REMOVE:
      remove(action._id);
      CMStore.emitChange();
      break;

    default:
      // no op
  }
});

module.exports = CMStore;