if Meteor.isClient

    FlowRouter.route '/admin/members', action: (params) ->
        BlazeLayout.render 'layout',
            nav: 'nav'
            sub_nav: 'admin_nav'
            main: 'user_table'
     
    FlowRouter.route '/admin/pages', action: (params) ->
        BlazeLayout.render 'layout',
            nav: 'nav'
            sub_nav: 'admin_nav'
            main: 'pages'
 
    Template.user_table.onCreated ->
        @autorun -> Meteor.subscribe 'members'
        @autorun -> Meteor.subscribe 'courses'
    
    
    Template.user_table.helpers
        members: -> 
            Meteor.users.find {}
            
        is_admin: -> 
            # console.log @
            Roles.userIsInRole(@_id, 'admin')
    
        is_beta: -> 
            # console.log @
            Roles.userIsInRole(@_id, 'beta')
    
        is_dev: -> 
            # console.log @
            Roles.userIsInRole(@_id, 'dev')
    
        in_sol: -> 
            # console.log @
            Roles.userIsInRole(@_id, 'sol')
    
        in_sol_demo: -> 
            # console.log @
            Roles.userIsInRole(@_id, 'sol_demo')
    
    
    
    
    Template.user_table.events
        'click .remove_admin': ->
            self = @
            swal {
                title: "Remove #{@username} from Admins?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove Privilages'
                closeOnConfirm: false
            }, ->
                Roles.removeUsersFromRoles self._id, 'admin'
                swal "Removed Admin Privilages from #{self.username}", "",'success'
                return
    
    
        'click .make_admin': ->
            self = @
            swal {
                title: "Make #{@username} an Admin?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Make Admin'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'admin'
                swal "Made #{self.username} an Admin", "",'success'
                return
    
        'click .remove_beta': ->
            self = @
            swal {
                title: "Remove #{@username} from beta users?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove Privilages'
                closeOnConfirm: false
            }, ->
                Roles.removeUsersFromRoles self._id, 'beta'
                swal "Removed beta Privilages from #{self.username}", "",'success'
                return
    
    
        'click .make_beta': ->
            self = @
            swal {
                title: "Make #{@username} a beta user?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Make beta'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'beta'
                swal "Made #{self.username} a beta user", "",'success'
                return
    
        'click .remove_dev': ->
            self = @
            swal {
                title: "Remove #{@username} from dev users?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove Privilages'
                closeOnConfirm: false
            }, ->
                Roles.removeUsersFromRoles self._id, 'dev'
                swal "Removed dev Privilages from #{self.username}", "",'success'
                return
    
    
        'click .add_dev': ->
            self = @
            swal {
                title: "Make #{@username} a dev user?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Make dev'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'dev'
                swal "Made #{self.username} a dev user", "",'success'
                return
    
        'click .remove_sol': ->
            self = @
            swal {
                title: "Remove #{@username} from SOL?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove Member Status'
                closeOnConfirm: false
            }, ->
                Roles.removeUsersFromRoles self._id, 'sol'
                swal "Removed #{self.username} from SOL", "",'success'
                return
    
    
        'click .add_sol': ->
            self = @
            swal {
                title: "Add #{@username} to SOL?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Add to SOL'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'sol'
                swal "Made #{self.username} a SOL Member", "",'success'
                return
    
    
    
        'click .remove_sol_demo': ->
            self = @
            swal {
                title: "Remove #{@username} from SOL Demo?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove Demo Member Status'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'sol_demo'
                swal "Removed #{self.username} from SOL Demo", "",'success'
                return
    
    
        'click .add_sol_demo': ->
            self = @
            swal {
                title: "Add #{@username} to SOL demo?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                animation: false
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Make Demo Member'
                closeOnConfirm: false
            }, ->
                Roles.addUsersToRoles self._id, 'sol_demo'

                swal "Added #{self.username} to SOL Demo", "",'success'
                return
    
    
    
 
 
        
if Meteor.isServer
    Meteor.publish 'members', ->
        match = {}
        Meteor.users.find match
         
