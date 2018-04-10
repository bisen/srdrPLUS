
document.addEventListener 'turbolinks:load', ->
  do ->
    $( '#end-message' ).hide()
##### loyloy #####
    loyloy = () ->
      console.log('loyloy')
      return

##### get_c_p #####
    #get a list of unlabeled_citations from server
    get_c_p = ( obj ) ->
      if obj.citations.length < 5
        $.ajax {
          type: 'GET'
          url: $( '#screen-assignment-json-url' ).text()
          success: 
            ( data ) -> 
              obj.citations = data.citations_projects 
        }
      return

##### nothing_to_label #####
    nothing_to_label = ( obj ) ->
      interval_id = setInterval( 
        -> 
          get_c_p( obj )
          if obj.citations.length == 0
            $( '#citation-row' ).hide()
            $( '#end-message' ).show()
          else
            $( '#citation-row' ).show()
            $( '#end-message' ).hide()
            clearInterval( interval_id )
      , 1000 )

##### next_citation #####
    #gets the first citation from citations and updates index with it
    next_citation = ( obj ) ->
      if obj.citations.length == 0
        nothing_to_label( obj )
        return
      obj.history.unshift obj.citations.shift()
      return

##### update_info #####
    update_info = ( obj ) ->
      current_citation = obj.history[ obj.index ]

      $( '#citation-name' ).text( current_citation.name )
      $( '#citation-abstract' ).text( current_citation.abstract )
      $( '#citation-pmid' ).text( current_citation.pmid )
      $( '#citation-refman' ).text( current_citation.refman )
      if $( '#journal-visible' ).text() != 'false'
        $( '#journal-name' ).text( current_citation.journal.name )
        $( '#journal-date' ).text( current_citation.journal.publication_date )
      else
        $( '#journal-div' ).hide()

      if $( '#authors-visible' ).text() != 'false'
        $( '#citation-authors' ).empty()
        s = true
        for k in current_citation.authors
          if s
            s = false
            $( '#citation-authors' ).append( k.name )
          else
            $( '#citation-authors' ).append( ', ' + k.name)
      else
        $( '#authors-div' ).hide()

      $( '#citation-keywords' ).empty()
      s = true
      for k in current_citation.keywords
        if s
          s = false
          $( '#citation-keywords' ).append( k.name )
        else
          $( '#citation-keywords' ).append( ', ' + k.name)

      $( '#yes-button' ).removeClass( 'secondary' )
      $( '#no-button' ).removeClass( 'secondary' )
      $( '#maybe-button' ).removeClass( 'secondary' )
      if obj.index > 0
        if current_citation.label_value == 'yes'
          $( '#yes-button' ).addClass( 'secondary' )
        else if current_citation.label_value == 'no'
          $( '#no-button' ).addClass( 'secondary' )
        else if current_citation.label_value == 'maybe'
          $( '#maybe-button' ).addClass( 'secondary' )
      return

##### send_label #####
    send_label = ( obj, label_value ) ->
      this.current_citation = obj.history[ obj.index ]
      # check if 'create' label or 'update'
      # if 'update', append label id
      is_patch = false
      if obj.index > 0 || obj.history[ obj.index ].label_value 
        is_patch = true

      label_url = $( '#labels-url' ).text()
      if is_patch
        label_url = label_url + '/' + obj.history[ obj.index ].label_id
      $.ajax {
        type: if is_patch > 0 then 'PATCH' else 'POST'
        url: label_url
        dataType: 'json'
        data: {
          utf8: '✓'
          authenticity_token: $( '#authenticity-token' ).text()
          label: {
            value: label_value
            citations_project_id: current_citation.id
          }
        }
        success:
          ( data ) -> 
            parent.current_citation.label_id = data.id
            parent.current_citation.label_value = label_value
            update_breadcrumb( current_citation )
      }  
      return

##### label_actions #####
    label_action = ( obj, label_value ) -> 
      send_label( obj, label_value )
      get_c_p( obj )
      # if we are updating previous label increment index
      if obj.index > 0
        update_index( obj, obj.index - 1 )
      # else add breadcrumb 
      else if obj.citations.length > 0
        next_citation( obj )
        add_breadcrumb( obj )
        obj.index = 1
        update_index( obj, 0 )
      update_info( obj )
      update_arrows( obj )
      return
      
##### update_arrows #####
    update_arrows = ( obj ) ->
      if obj.index < obj.history.length - 1
        $( '#previous-button' ).removeClass( 'disabled' )
      else
        $( '#previous-button' ).addClass( 'disabled' )

      if obj.index > 0
        $( '#next-button' ).removeClass( 'disabled' )
      else
        $( '#next-button' ).addClass( 'disabled' )
      return

##### start_screening #####
    start_screening = ( citations ) ->
      # session state is stored in state_obj, and this object is passed in methods that modify the state
      state_obj = { citations: citations, history: [ ], index: 0, done: 'false' }
      next_citation( state_obj )
      add_breadcrumb( state_obj )
      update_index( state_obj, 0 )
      update_info( state_obj )
      update_arrows( state_obj )

      $( '#yes-button' ).click ->
        $( "#label-input[value='yes']" ).prop( 'checked', true )
        label_action( state_obj, 'yes' ) 

      $( '#maybe-button' ).click ->
        $( "#label-input[value='maybe']" ).prop( 'checked', true )
        label_action( state_obj, 'maybe' ) 

      $( '#no-button' ).click ->
        $( "#label-input[value='no']" ).prop( 'checked', true )
        label_action( state_obj, 'no' ) 

      next_button = $( '#next-button' ) 
      previous_button = $( '#previous-button' ) 
      switch_button = $( '#switch-button' )

      next_button.click ->
        if !next_button.hasClass( 'disabled' )
          update_index( state_obj, state_obj.index - 1 )
          update_arrows( state_obj )
          update_info( state_obj )

      previous_button.click ->
        if !previous_button.hasClass( 'disabled' )
          update_index( state_obj, state_obj.index + 1 )
          update_arrows( state_obj )
          update_info( state_obj )

      switch_button.click ->
        if switch_button.val() == 'OFF'
          console.log( 'loyloy' )
          switch_to_list( state_obj )  
          switch_button.val( 'ON' )
        else
          switch_to_screening( state_obj )  
          switch_button.val( 'OFF' )
      return

##### add_breadcrumb #####
    add_breadcrumb = ( obj ) ->
      next_index = obj.history.length
      breadcrumb_id = 'breadcrumb_' + next_index
      id = next_index
      button = $( '<input/>' ).attr( { type: 'button', id: breadcrumb_id, class: 'button' } ) 
      button.click -> 
        update_index( obj, obj.history.length - next_index )
        update_info( obj )
        update_arrows( obj )

      $( '#breadcrumb-group' ).append( button );  
      obj.history[ obj.index ].breadcrumb_id = breadcrumb_id
      obj.history[ obj.index ].id = id
      return

##### update_breadcrumb #####
    update_breadcrumb = ( citation ) ->
      button = $( '#' + citation.breadcrumb_id ) 
      label = citation.label_value
      button.removeClass( 'success alert' )
      if label == 'yes'
        button.addClass( 'success' )
      else if label == 'no'
        button.addClass( 'alert' )
      return

##### update_index #####
    update_index = ( obj, new_index ) ->
      old_breadcrumb_id = obj.history[ obj.index ].breadcrumb_id
      obj.index = new_index
      new_breadcrumb_id = obj.history[ new_index ].breadcrumb_id
      $( '#' + old_breadcrumb_id ).removeClass( 'hollow' )
      $( '#' + new_breadcrumb_id ).addClass( 'hollow' )
      return

##### switch_to_list #####
    switch_to_list = ( obj ) ->
      $( '#citations-list' ).empty()
      next_index = 0
      for c in obj.history
        citation_element = 
          $( '<div></div>' ).attr( { id: 'citation-element-' + c.id, class: 'callout', index: next_index } )
        next_index++
        citation_title = 
          $( '<div>' + c.name + '<div/>' ).attr( { id: '#citation-element-title-' + c.breadcrumb_id } )
        
        #set up buttons
        buttons_wrapper =  $( '<div><div/>' ).attr( { id: 'buttons-wrapper' + c.id } )
        citation_buttons = 
          $( '<div><div/>' ).attr( { id: 'citation-buttons-' + c.id, class: 'button-group' } )
        citation_button_yes =
          $( '<div>Yes</div>' ).attr( { id: 'citation-button-yes-' + c.id, class: 'button' } )
        citation_button_maybe = 
          $( '<div>Maybe</div>' ).attr( { id: 'citation-button-maybe-' + c.id, class: 'button' } )
        citation_button_no = 
          $( '<div>No</div>' ).attr( { id: 'citation-button-no-' + c.id, class: 'button' } )

        

        # set click behavior
        citation_element.click ->
          update_index( obj, $(this).attr("index") )
          update_info( obj )
          update_arrows( obj )
          switch_to_screening( obj )
        

        # for layout
        buttons_wrapper.css('float','right')
        citation_element.addClass('row')
        citation_title.addClass('columns medium-9')
        citation_buttons.addClass('columns medium-4')

        # highlight button based on label value
        if c.label_value == 'yes'
          citation_button_yes.addClass( 'secondary' )
        else if c.label_value == 'no'
          citation_button_no.addClass( 'secondary' )
        else if c.label_value == 'maybe'
          citation_button_maybe.addClass( 'secondary' )
        
        # place divs
        citation_element.append( citation_title )
        buttons_wrapper.append( citation_button_yes )
        buttons_wrapper.append( citation_button_maybe )
        buttons_wrapper.append( citation_button_no )
        citation_buttons.append( buttons_wrapper )
        citation_element.append( citation_buttons )
        $( '#citations-list' ).append( citation_element )

      #hide regular view, show list view
      $( '#citations-list' ).show()
      $( '#screen-div' ).hide()
      
##### switch_to_screening #####
    switch_to_screening = ( obj ) ->
      $( '#citations-list' ).empty()
      $( '#citations-list' ).hide()
      $( '#screen-div' ).show()

    $.ajax {
      type: 'GET'
      url: $( '#screen-assignment-json-url' ).text()
      success:
        ( data ) ->
          $( '#screen-div' ).show()
          start_screening( data.citations_projects ) 
    }
  return # END do ->
return # END document.addEventListener 'turbolinks:load', ->
