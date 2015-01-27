class Index extends App.ControllerContent
  constructor: ->
    super
    @render()

  render: ->
    @html App.view('layout_ref/index')()

App.Config.set( 'layout_ref', Index, 'Routes' )


class Content extends App.ControllerContent
  events:
    'hide.bs.dropdown .js-recipientDropdown': 'hideOrganizationMembers'
    'click .js-organization':                 'showOrganizationMembers'
    'click .js-back':                         'hideOrganizationMembers'

  constructor: ->
    super
    @render()

    @dragEventCounter = 0
    @attachments = []

    for avatar in @$('.user.avatar')
      avatar = $(avatar)
      size = switch
        when avatar.hasClass('size-80') then 80
        when avatar.hasClass('size-50') then 50
        else 40
      @createUniqueAvatar avatar, size, avatar.data('firstname'), avatar.data('lastname'), avatar.data('userid')

  createUniqueAvatar: (holder, size, firstname, lastname, id) ->
    width = 300
    height = 226

    holder.addClass 'unique'

    rng = new Math.seedrandom(id);
    x = rng() * (width - size)
    y = rng() * (height - size)
    holder.css('background-position', "-#{ x }px -#{ y }px")

    holder.text(firstname[0] + lastname[0])

  render: ->
    @html App.view('layout_ref/content')()

  showOrganizationMembers: (e) =>
    e.stopPropagation()

    listEntry = $(e.currentTarget)
    organizationId = listEntry.data('organization-id')

    @recipientList = @$('.recipientList')
    @organizationList = @$("##{ organizationId }")

    # move organization-list to the right and slide it in

    $.Velocity.hook(@organizationList, 'translateX', '100%')
    @organizationList.removeClass('hide')

    @organizationList.velocity
      properties:
        translateX: 0
      options:
        speed: 300

    # fade out list

    @recipientList.velocity
      properties:
        translateX: '-100%'
      options:
        speed: 300
        complete: => @recipientList.height(@organizationList.height())

  hideOrganizationMembers: (e) =>
    e && e.stopPropagation()

    return if !@organizationList

    # fade list back in

    @recipientList.velocity
      properties:
        translateX: 0
      options:
        speed: 300

    # reset list height

    @recipientList.height('')

    # slide out organization-list and hide it
    @organizationList.velocity
      properties:
        translateX: '100%'
      options:
        speed: 300
        complete: => @organizationList.addClass('hide')

App.Config.set( 'layout_ref/content', Content, 'Routes' )


class CommunicationOverview extends App.ControllerContent
  events:
    'click .js-unfold': 'unfold'

  constructor: ->
    super
    @render()

    @bindScrollPageHeader()

  bindScrollPageHeader: ->
    pageHeader = @$('.page-header')
    scrollHolder = pageHeader.scrollParent()
    scrollBody = scrollHolder.get(0).scrollHeight - scrollHolder.height()

  unfold: (e) ->
    container = $(e.currentTarget).parents('.textBubble-content')
    overflowContainer = container.find('.textBubble-overflowContainer')

    overflowContainer.velocity
      properties:
        opacity: 0
      options:
        duration: 300

    container.velocity
      properties:
        height: container.attr('data-height')
      options:
        duration: 300
        complete: -> overflowContainer.addClass('hide');

  render: ->
    @html App.view('layout_ref/communication_overview')()

    # set see more options
    previewHeight = 240
    @$('.textBubble-content').each( (index) ->
      bubble = $( @ )
      heigth = bubble.height()
      if heigth > (previewHeight + 30)
        bubble.attr('data-height', heigth)
        bubble.css('height', "#{previewHeight}px")
      else
        bubble.parent().find('.textBubble-overflowContainer').addClass('hide')
    )

App.Config.set( 'layout_ref/communication_overview', CommunicationOverview, 'Routes' )


class LayoutRefCommunicationReply extends App.ControllerContent
  elements:
    '.js-textarea' :                'textarea'
    '.attachmentPlaceholder':       'attachmentPlaceholder'
    '.attachmentPlaceholder-inputHolder': 'attachmentInputHolder'
    '.attachmentPlaceholder-hint':  'attachmentHint'
    '.ticket-edit':                 'ticketEdit'
    '.attachments':                 'attachmentsHolder'
    '.attachmentUpload':            'attachmentUpload'
    '.attachmentUpload-progressBar':'progressBar'
    '.js-percentage':               'progressText'
    '.textBubble':                 'textBubble'

  events:
    'focus .js-textarea':                     'open_textarea'
    'input .js-textarea':                     'detect_empty_textarea'
    'dragenter':                              'onDragenter'
    'dragleave':                              'onDragleave'
    'drop':                                   'onFileDrop'
    'change input[type=file]':                'onFilePick'

  constructor: ->
    super

    if @content is 'no_content'
      @content = ''
    else if @content is 'content'
      @content = "some content la la la la"
    else
      @content = "<p>some</p><p>multiline content</p>1<p>2</p><p>3</p>"

    @render()

    @textareaHeight =
      open: 148
      closed: 20

    @open_textarea(null, true) if @content

    @dragEventCounter = 0
    @attachments = []

  render: ->
    @html App.view('layout_ref/communication_reply')(
      content: @content
    )

    @$('[contenteditable]').ce({
      mode:      'textonly'
      multiline: true
      maxlength: 2500
    })

    @$('[contenteditable]').textmodule()

  detect_empty_textarea: =>
    if !@textarea.text()
      @add_textarea_catcher()
    else
      @remove_textarea_catcher()

  open_textarea: (event, withoutAnimation) =>
    if !@ticketEdit.hasClass('is-open')
      duration = 300

      if withoutAnimation
        duration = 0

      @ticketEdit.addClass('is-open')

      @textarea.velocity
        properties:
          minHeight: "#{ @textareaHeight.open - 38 }px"
        options:
          duration: duration
          easing: 'easeOutQuad'
          complete: => @add_textarea_catcher()

      @textBubble.velocity
        properties:
          paddingBottom: 28
        options:
          duration: duration
          easing: 'easeOutQuad'

      # scroll to bottom
      # @textarea.velocity "scroll",
      #   container: @textarea.scrollParent()
      #   offset: 99999
      #   duration: 300
      #   easing: 'easeOutQuad'
      #   queue: false

      # @editControlItem.velocity "transition.slideRightIn",
      #   duration: 300
      #   stagger: 50
      #   drag: true

      # move attachment text to the left bottom (bottom happens automatically)

      @attachmentPlaceholder.velocity
        properties:
          translateX: -@attachmentInputHolder.position().left + "px"
        options:
          duration: duration
          easing: 'easeOutQuad'

      @attachmentHint.velocity
        properties:
          opacity: 0
        options:
          duration: duration

  add_textarea_catcher: ->
    @textareaCatcher = new App.clickCatcher
      holder: @ticketEdit.offsetParent()
      callback: @close_textarea
      zIndexScale: 4

  remove_textarea_catcher: ->
    return if !@textareaCatcher
    @textareaCatcher.remove()
    @textareaCatcher = null

  close_textarea: =>
    @remove_textarea_catcher()
    if !@textarea.text() && !@attachments.length

      @textarea.velocity
        properties:
          minHeight: "#{ @textareaHeight.closed }px"
        options:
          duration: 300
          easing: 'easeOutQuad'
          complete: => @ticketEdit.removeClass('is-open')

      @textBubble.velocity
        properties:
          paddingBottom: 10
        options:
          duration: 300
          easing: 'easeOutQuad'

      @attachmentPlaceholder.velocity
        properties:
          translateX: 0
        options:
          duration: 300
          easing: 'easeOutQuad'

      @attachmentHint.velocity
        properties:
          opacity: 1
        options:
          duration: 300

      # @editControlItem.css('display', 'none')

  onDragenter: (event) =>
    # on the first event,
    # open textarea (it will only open if its closed)
    @open_textarea() if @dragEventCounter is 0

    @dragEventCounter++
    @ticketEdit.addClass('is-dropTarget')

  onDragleave: (event) =>
    @dragEventCounter--

    @ticketEdit.removeClass('is-dropTarget') if @dragEventCounter is 0

  onFileDrop: (event) =>
    event.preventDefault()
    event.stopPropagation()
    files = event.originalEvent.dataTransfer.files
    @ticketEdit.removeClass('is-dropTarget')

    @queueUpload(files)

  onFilePick: (event) =>
    @open_textarea()
    @queueUpload(event.target.files)

  queueUpload: (files) ->
    @uploadQueue ?= []

    # add files
    for file in files
      @uploadQueue.push(file)

    @workOfUploadQueue()

  workOfUploadQueue: =>
    if !@uploadQueue.length
      return

    file = @uploadQueue.shift()
    # console.log "working of", file, "from", @uploadQueue
    @fakeUpload file.name, file.size, @workOfUploadQueue

  humanFileSize: (size) =>
    i = Math.floor( Math.log(size) / Math.log(1024) )
    return ( size / Math.pow(1024, i) ).toFixed(2) * 1 + ' ' + ['B', 'kB', 'MB', 'GB', 'TB'][i]

  updateUploadProgress: (progress) =>
    @progressBar.width(progress + "%")
    @progressText.text(progress)

    if progress is 100
      @attachmentPlaceholder.removeClass('hide')
      @attachmentUpload.addClass('hide')

  fakeUpload: (fileName, fileSize, callback) ->
    @attachmentPlaceholder.addClass('hide')
    @attachmentUpload.removeClass('hide')

    progress = 0;
    duration = fileSize / 1024

    for i in [0..100]
      setTimeout @updateUploadProgress, i*duration/100 , i

    setTimeout (=> 
      callback()
      @renderAttachment(fileName, fileSize)
    ), duration

  renderAttachment: (fileName, fileSize) =>
    @attachments.push([fileName, fileSize])
    @attachmentsHolder.append App.view('ticket_zoom/attachment')
      fileName: fileName
      fileSize: @humanFileSize(fileSize)


App.Config.set( 'layout_ref/communication_reply/:content', LayoutRefCommunicationReply, 'Routes' )



class ContentSidebarRight extends App.ControllerContent
  constructor: ->
    super
    @render()

  render: ->
    @html App.view('layout_ref/content_sidebar_right')()

App.Config.set( 'layout_ref/content_sidebar_right', ContentSidebarRight, 'Routes' )


class ContentSidebarRightSidebarOptional extends App.ControllerContent
  constructor: ->
    super
    @render()

  render: ->
    @html App.view('layout_ref/content_sidebar_right_sidebar_optional')()

App.Config.set( 'layout_ref/content_sidebar_right_sidebar_optional', ContentSidebarRightSidebarOptional, 'Routes' )


class ModalForm extends App.ControllerModal
  constructor: ->
    super
    @head  = '123 some title'
    @cancel = true
    @button = true

    @render()

  render: ->
    controller = new App.ControllerForm(
      model: App.User
      autofocus: true
    )
    @content = controller.form

    @show()

  onHide: =>
    window.history.back()

  onSubmit: (e) =>
    e.preventDefault()
    params = App.ControllerForm.params( $(e.target).closest('form') )
    console.log('params', params)

App.Config.set( 'layout_ref/modal_form', ModalForm, 'Routes' )


class ModalText extends App.ControllerModal
  constructor: ->
    super
    @head = '123 some title'

    @render()

  render: ->
    @show( App.view('layout_ref/content')() )

  onHide: =>
    window.history.back()

App.Config.set( 'layout_ref/modal_text', ModalText, 'Routes' )



class ContentSidebarTabsRight extends App.ControllerContent
  elements:
    '.tabsSidebar'  : 'sidebar'

  constructor: ->
    super
    @render()

    changeCustomerTicket = ->
      alert('change customer ticket')

    editCustomerTicket = ->
      alert('edit customer ticket')

    changeCustomerCustomer = ->
      alert('change customer customer')

    editCustomerCustomer = ->
      alert('edit customer customer')


    items = [
        head: 'Ticket Settings'
        name: 'ticket'
        icon: 'message'
        callback: (el) ->
          el.html('some ticket')
        actions: [
            title:    'Change Customer'
            name:     'change-customer'
            callback: changeCustomerTicket
          ,
            title:    'Edit Customer'
            name:     'edit-customer'
            callback: editCustomerTicket
        ]
      ,
        head: 'Customer'
        name: 'customer'
        icon: 'person'
        callback: (el) ->
          el.html('some customer')
        actions: [
            title:    'Change Customer'
            name:     'change-customer'
            callback: changeCustomerCustomer
          ,
            title:    'Edit Customer'
            name:     'edit-customer'
            callback: editCustomerCustomer
        ]
      ,
        head: 'Organization'
        name: 'organization'
        icon: 'group'
    ]

    new App.Sidebar(
      el:     @sidebar
      items:  items
    )

  render: ->
    @html App.view('layout_ref/content_sidebar_tabs_right')()

App.Config.set( 'layout_ref/content_sidebar_tabs_right', ContentSidebarTabsRight, 'Routes' )


class ContentSidebarLeft extends App.ControllerContent
  constructor: ->
    super
    @render()

  render: ->
    @html App.view('layout_ref/content_sidebar_left')()

App.Config.set( 'layout_ref/content_sidebar_left', ContentSidebarLeft, 'Routes' )


class App.ControllerWizard extends App.ControllerContent
  elements:
    '[data-slide]':   'slides'

  events:
    'click [data-target]': 'navigate'
    'click [data-action]': 'action'

  constructor: ->
    super

  action: (e) =>
    button = $(e.currentTarget)

    switch button.attr('data-action')
      when "reveal" then @showNextButton button

  showNextButton: (sibling) ->
    sibling.parents('.wizard-slide').find('.btn.hide').removeClass('hide')

  navigate: (e) =>
    target = $(e.currentTarget).attr('data-target')
    targetSlide = @$("[data-slide=#{ target }]")
    console.log(e, target, targetSlide)

    if targetSlide
      @goToSlide targetSlide

  goToSlide: (targetSlide) =>
    @slides.addClass('hide')
    targetSlide.removeClass('hide')

    if targetSlide.attr('data-hide')
      setTimeout @goToSlide, targetSlide.attr('data-hide'), targetSlide.next()


class ImportWizard extends App.ControllerWizard
  elements:
    '#otrs-link':     'otrsLink'
    '.input-feedback':'inputFeedback'

  constructor: ->
    super
    @render()

    # wait 500 ms after the last user input before we check the link
    @otrsLink.on 'input', _.debounce(@checkOtrsLink, 600) 

  checkOtrsLink: (e) =>
    if @otrsLink.val() is ""
      @inputFeedback.attr('data-state', '')
      return

    @inputFeedback.attr('data-state', 'loading')

    # send fake callback
    if @otrsLink.val() is '1337'
      state = 'success'
    else
      state = 'error'

    setTimeout @otrsLinkCallback, 1500, state

  otrsLinkCallback: (state) =>
    @inputFeedback.attr('data-state', state)

    @showNextButton @inputFeedback if state is 'success'

  render: ->
    @html App.view('layout_ref/import_wizard')()

App.Config.set( 'layout_ref/import_wizard', ImportWizard, 'Routes' )

class ReferenceUserProfile extends App.ControllerContent

  constructor: ->
    super
    @render()

  render: ->
    @html App.view('layout_ref/user_profile')()

App.Config.set( 'layout_ref/user_profile', ReferenceUserProfile, 'Routes' )

class ReferenceOrganizationProfile extends App.ControllerContent

  constructor: ->
    super
    @render()

  render: ->
    @html App.view('layout_ref/organization_profile')()

App.Config.set( 'layout_ref/organization_profile', ReferenceOrganizationProfile, 'Routes' )

class ReferenceSetupWizard extends App.ControllerWizard
  elements:
    '.logo-preview': 'logoPreview'
    '#agent_email': 'agentEmail'
    '#agent_first_name': 'agentFirstName'
    '#agent_last_name': 'agentLastName'

  events:
    'change .js-upload': 'onLogoPick'
    'click .js-inviteAgent': 'inviteAgent'

  constructor: ->
    super
    @render()

  render: ->
    @html App.view('layout_ref/setup')()

  onLogoPick: (event) =>
    reader = new FileReader()

    reader.onload = (e) =>
      @logoPreview.attr('src', e.target.result)

    reader.readAsDataURL(event.target.files[0])

  inviteAgent: =>
    firstname = @agentFirstName.val()
    lastname = @agentLastName.val()

    App.Event.trigger 'notify', {
      type:    'success'
      msg:     App.i18n.translateContent( "Invitation sent to #{ firstname } #{ lastname }" )
      timeout: 3500
    }

    @agentEmail.add(@agentFirstName).add(@agentLastName).val('')
    @agentFirstName.focus()

App.Config.set( 'layout_ref/richtext', ReferenceSetupWizard, 'Routes' )

class RichText extends App.ControllerContent
  constructor: ->
    super
    @render()

    @$('.js-text-oneline').ce({
      mode:      'textonly'
      multiline: false
      maxlength: 250
    })

    @$('.js-text-multiline').ce({
      mode:      'textonly'
      multiline: true
      maxlength: 250
    })

    @$('.js-text-richtext').ce({
      mode:      'richtext'
      multiline: true
      maxlength: 250
    })
    return

    @$('.js-textarea').on('keyup', (e) =>
      console.log('KU')
      textarea = @$('.js-textarea')
      App.Utils.htmlCleanup(textarea)
    )

    @$('.js-textarea').on('paste', (e) =>
      console.log('paste')
      #console.log('PPP', e, e.originalEvent.clipboardData)

      execute = =>

        # add marker for cursor
        getFirstRange = ->
          sel = rangy.getSelection();
          if sel.rangeCount
            sel.getRangeAt(0)
          else
            null
        range = getFirstRange()
        if range
          el = document.createElement('span')
          $(el).attr('data-cursor', 1)
          range.insertNode(el)
          rangy.getSelection().setSingleRange(range)

        # cleanup
        textarea = @$('.js-textarea')
        App.Utils.htmlCleanup(textarea)

        # remove marker for cursor
        textarea.find('[data-cursor=1]').focus()
        textarea.find('[data-cursor=1]').remove()
      @delay( execute, 1)

      return
    )
    #editable.style.borderColor = '#54c8eb';
    #aloha(editable);
    return

  render: ->
    @html App.view('layout_ref/richtext')()

App.Config.set( 'layout_ref/richtext', RichText, 'Routes' )

class LocalModalRef extends App.ControllerContent

  constructor: ->
    super
    @render()

  render: ->
    @html App.view('layout_ref/local_modal')()

App.Config.set( 'layout_ref/local_modal', LocalModalRef, 'Routes' )

class loadingPlaceholderRef extends App.ControllerContent

  constructor: ->
    super
    @render()

  render: ->
    @html App.view('layout_ref/loading_placeholder')()

App.Config.set( 'layout_ref/loading_placeholder', loadingPlaceholderRef, 'Routes' )

class insufficientRightsRef extends App.ControllerContent

  constructor: ->
    super
    @render()

  render: ->
    @html App.view('layout_ref/insufficient_rights')()

App.Config.set( 'layout_ref/insufficient_rights', insufficientRightsRef, 'Routes' )


class errorRef extends App.ControllerContent

  constructor: ->
    super
    @render()

  render: ->
    @html App.view('layout_ref/error')()

App.Config.set( 'layout_ref/error', errorRef, 'Routes' )

App.Config.set( 'LayoutRef', { prio: 1700, parent: '#current_user', name: 'Layout Reference', target: '#layout_ref', role: [ 'Admin' ] }, 'NavBarRight' )