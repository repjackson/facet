if Meteor.isClient
    Template.check_in_button.events
        'click .check_in': ->
            self = @
            swal {
                title: "Check in #{self.profile.first_name} #{self.profile.last_name}?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Check In'
                closeOnConfirm: false
            }, ->
                Meteor.call 'check_in_user', self._id, ->
                    swal { 
                        title: "Checked in #{self.name}"
                        type: 'success'
                        animation: false
                    }
                    return
    
            Meteor.users.update @_id,
                $set: checked_in: true
    
        'click .check_out': ->
            self = @
            swal {
                title: "Check out #{self.profile.first_name} #{self.profile.last_name}?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Check Out'
                closeOnConfirm: false
            }, ->
                Meteor.call 'check_out_user', self._id, ->
                    swal { 
                        title: "Checked out #{self.name}"
                        type: 'success'
                        animation: false
                    }
                    return



