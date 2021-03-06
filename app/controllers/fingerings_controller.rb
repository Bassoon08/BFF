class FingeringsController < ApplicationController
  before_filter :require_login
  before_filter :require_admin, :only => [:destroy]
  
  def index
    if(!current_user.isAdmin)
	@fingerings = Fingering.where(approved: true).order('octave ASC, note_name ASC, accidental ASC, keytype DESC, admin_order ASC') # only show approved fingerings to non-admin
    else
        @fingerings = Fingering.order('octave ASC, note_name ASC, accidental ASC, keytype DESC, admin_order ASC')
    end

# uncomment the following lines to update the database (split note_tone into separate columns)
#    @allFingerings = Fingering.all.sort_by(&:note_tone)
#    @allFingerings.each do |f|
#       @origString = f.note_tone
#       @accidental = @origString.split('_')[1]
#    	@accidental = @accidental.split(',')[0] # only look at first note if multiple
#       @octave = @origString[3]
#       @note_name = @origString[2]
#       if @accidental == "flat"
#         f.accidental = 1
#       elsif @accidental == "natural"
#         f.accidental = 2
#       else
#         f.accidental = 3
#       end
#       f.octave = @octave
#       f.note_name = @note_name
#       f.save
#    end

#uncomment the following lines to update the database (reset all admin_order values)
#    @seen = Array.new
#    @allFingerings = Fingering.all.sort_by(&:note_tone)
#    @allFingerings.each do |f|
#      if(@seen.index(f.note_tone) == nil)
#        @seen.push(f.note_tone)
#        @seen.push(getEnharmonicEquivalent(f.note_tone))
#        @fingerings11 = Fingering.where('note_tone = ? OR note_tone = ?', f.note_tone, getEnharmonicEquivalent(f.note_tone)).order('keytype DESC')
#        for i in 0..(@fingerings11.size - 1) do
#          @fingerings11[i][:admin_order] = i + 1
#          @fingerings11[i].save
#        end
#      end
#    end

# uncomment the following lines to update Susan's username from shess@uidaho.edu to shess
#    @susan = User.where('login = ?', "shess@uidaho.edu").update_all(:login => "shess")
#    @susanFingerings = Fingering.where('user_name = ?', "shess@uidaho.edu").update_all(:user_name => "shess")
    
    
    respond_to do |format|
      format.html { }
      if current_user.isAdmin
        format.json { render json: @fingerings }
      end
    end
  end
  
  #returns the total number of fingerings which match the given note_tone (if enharmonic, return number of fingerings which match note_tone or enharmonic equivalent)
  def count_fingerings(note)
    return Fingering.where("note_tone = ?", note).size + Fingering.where("note_tone = ?", getEnharmonicEquivalent(note)).size
  end
  helper_method :count_fingerings

  def search
    @user = session[:user]
    @fingering = Fingering.new(params[:fingering])
    @note_tone = @fingering.note_tone
    
    respond_to do |format|
      format.html { }
      if current_user.isAdmin
        format.json { render json: @fingering }
      end
    end
  end

  #given a note, return the enharmonic equivalent of the note, if an enharmonic equivalent exists (i.e. c sharp returns d flat)
  def getEnharmonicEquivalent(note_tone)
    if (note_tone[0] == "1")
      @origString = note_tone
      @accidental = @origString.split('_')[1]
      @accidental = @accidental.split(',')[0] # only look at first note if multiple
      @octave = @origString[3]
      @note_name = @origString[2]
      
      if (@accidental == "sharp")
        if (@note_name == "a")
          return "1:b" + @octave + "_flat"
        elsif (@note_name == "c")
          return "1:d" + @octave + "_flat"
        elsif (@note_name == "d")
          return "1:e" + @octave + "_flat"
        elsif (@note_name == "f")
          return "1:g" + @octave + "_flat"
        elsif (@note_name == "g")
          return "1:a" + @octave + "_flat"
        end
      elsif (@accidental == "flat")
        if (@note_name == "b")
          return "1:a" + @octave + "_sharp"
        elsif (@note_name == "d")
          return "1:c" + @octave + "_sharp"
        elsif (@note_name == "e")
          return "1:d" + @octave + "_sharp"
        elsif (@note_name == "g")
          return "1:f" + @octave + "_sharp"
        elsif (@note_name == "a")
          return "1:g" + @octave + "_sharp"
        end
      end
    end

    #if we haven't returned by now, return a default value (no enharmonic found)
    return ""
  end
  
  def search_results
    if (params != nil && params[:fingering] != nil && params[:fingering][:keytype] != nil)
      if params[:fingering][:note_tone] != nil
        @enharmonic_note = getEnharmonicEquivalent(params[:fingering][:note_tone])
      else
        @enharmonic_note = ""
      end

      if (params[:fingering][:keytype] == "standard" || params[:fingering][:keytype] == "alternate")
        if(!current_user.isAdmin)
          @Results = Fingering.where('note_tone = ? OR note_tone = ?', params[:fingering][:note_tone], @enharmonic_note).where(approved:true).where(keytype: params[:fingering][:keytype]).order('admin_order ASC')
        else
          @Results = Fingering.where('note_tone = ? OR note_tone = ?', params[:fingering][:note_tone], @enharmonic_note).where(keytype: params[:fingering][:keytype]).order('admin_order ASC')
        end
      elsif #(params[:fingering][:keytype] == "standard/alternate" or some other case)
        if(!current_user.isAdmin)
          @Results = Fingering.where('note_tone = ? OR note_tone = ?', params[:fingering][:note_tone], @enharmonic_note).where(approved:true).order('admin_order ASC')
        else
          @Results = Fingering.where('note_tone = ? OR note_tone = ?', params[:fingering][:note_tone], @enharmonic_note).order('admin_order ASC')
        end
      end

      if @Results != []
        @fingerings = @Results.paginate(:page => params[:page], :per_page => 1).order('admin_order ASC')
      else
        flash[:notice] = "No fingerings match the requested note(s)."
      end
    else
      flash[:notice] = "An error occured (likely while switching between the mobile and full site). Try refreshing or going back and re-entering the search parameters."
    end  
  end

  def show
    @fingering        = Fingering.find(params[:id])
    @fingering_status = @fingering.fingering_status
    @note_tone        = @fingering.note_tone

    params[:fingering] = @fingering
    params[:fingering]["note_tone"] = @note_tone
    params[:fingering]["show_first"] = true

    Fingering.update_all(:show_first => false)
    Fingering.update(params[:id], :show_first => true)

    @enharmonic_note = getEnharmonicEquivalent(@note_tone)

    if(!current_user.isAdmin)
         @fingerings = Fingering.where('note_tone = ? OR note_tone = ?', @note_tone, @enharmonic_note).where(approved:true).paginate(:page => params[:page], :per_page => 1, :order => 'show_first DESC').order('admin_order ASC')
    else
         @fingerings = Fingering.where('note_tone = ? OR note_tone = ?', @note_tone, @enharmonic_note).paginate(:page => params[:page], :per_page => 1, :order => 'show_first DESC').order('admin_order ASC')
    end

    respond_to do |format|
      format.html { }
      if current_user.isAdmin
        format.json { render json: @fingering }
      end
    end
  end

  def new
    @fingering = Fingering.new(params[:fingering])
  end

  def saveIndividualFingeringFromTrill(position, duringApproval)
    #the order of operations in this function from here until the line "@fingering.votes_beginner     = 0" are critical
    #if at all possible, you should avoid changing things around in that particular block of code

    if duringApproval
      #admin marked checkbox to add an individual fingering while approving a submitted trill/combination fingering
      #else if !duringApproval admin marked checkbox to add an individual fingerings while submitting a new trill/combination fingering
      
      #get trill/combination fingering that is pending approval
      @approval_fingering = Fingering.find(params[:id])

      #construct params[:fingering] from the basic contents of the approval fingering (we don't want approval fingering id, and other specific info)
      params[:fingering] = {}
      params[:fingering][:fingering_status] = @approval_fingering.fingering_status
      params[:fingering][:note_tone] = @approval_fingering.note_tone
      params[:fingering][:keytype] = @approval_fingering.keytype
      params[:fingering][:source] = @approval_fingering.source
      params[:fingering][:comments] = @approval_fingering.comments
    end

    if position == "first"
      @new_fingering_status = "1:" + params[:fingering][:fingering_status].sub("2", "").sub(":", "").split(",")[0]
      @new_note_tone = "1:" + params[:fingering][:note_tone].sub("2", "").sub(":", "").split(",")[0]
    elsif position == "second"
      @new_fingering_status = "1:" + params[:fingering][:fingering_status].sub("2", "").sub(":", "").split(",")[1]
      @new_note_tone = "1:" + params[:fingering][:note_tone].sub("2", "").sub(":", "").split(",")[1]
    end

    @same_fingerings = Fingering.where(:note_tone => @new_note_tone).where(:fingering_status => @new_fingering_status)

    if (@same_fingerings != []) #if fingering already exists, return and don't add duplicate to database
      return
    end
      
    @fingering = Fingering.create!(params[:fingering])

    #important that @fingering.comments is set before updating @fingering.note_tone since comments uses old note_tone when doing pretty_notes 
    if duringApproval
      @fingering.comments = "Auto-generated fingering: " + position + " note in " + @fingering.pretty_notes + " fingering combination submitted by " + @approval_fingering.user_name + "."
    else
      @fingering.comments = "Auto-generated fingering: " + position + " note in " + @fingering.pretty_notes + " fingering combination submitted by " + current_user.login + "."
    end

    @fingering.keytype = "alternate"
    @fingering.source = params[:fingering][:source]
    @fingering.fingering_status = @new_fingering_status
    @fingering.note_tone = @new_note_tone
    @fingering.votes_beginner     = 0
    @fingering.votes_intermediate = 0
    @fingering.votes_advanced     = 0
    @fingering.votes_professional = 0
    @fingering.dvotes_beginner     = 0
    @fingering.dvotes_intermediate = 0
    @fingering.dvotes_advanced     = 0
    @fingering.dvotes_professional = 0
    @fingering.user_name = current_user.login

    #not exactly sure why, but when we call count_fingerings() here, it only counts existing ones, it doesn't also count this one we are constructing currently
    @fingering.admin_order = count_fingerings(@new_note_tone) + 1
    
    #should only ever enter this function when admin, but still safe to do this check
    if(!current_user.isAdmin)
        @fingering.approved  = false
    else
        @fingering.approved = true
    end
    
    @fingering.score = 0

    @origString = @fingering.note_tone
    @accidental = @origString.split('_')[1]
    @accidental = @accidental.split(',')[0] # only look at first note if multiple
    @octave = @origString[3]
    @note_name = @origString[2]
    if @accidental == "flat"
      @fingering.accidental = 1
    elsif @accidental == "natural"
      @fingering.accidental = 2
    else
      @fingering.accidental = 3
    end
    @fingering.octave = @octave
    @fingering.note_name = @note_name

    if @fingering.save
      if (!current_user.isAdmin)
        #shouldn't ever get here since current_user should always be admin, but leave the check just in case
        @fingering.send_fingering_submitted #send email to admins if regular user submits a new fingering
      end
    else
      render action: "new"
    end
  end    

  def create
    if params[:save_first] != nil && params[:save_first] == "on"
      saveIndividualFingeringFromTrill("first", false)
    end

    if params[:save_second] != nil && params[:save_second] == "on"
      saveIndividualFingeringFromTrill("second", false)
    end

    if !current_user.isAdmin #non admins can no longer specify if a fingering they entered is standard/alaternate, force it to always be alternate
      params[:fingering]["keytype"] = "alternate"
    end

    @same_fingerings = Fingering.where(:note_tone => params[:fingering][:note_tone]).where(:fingering_status => params[:fingering][:fingering_status])

    if (@same_fingerings != []) 
      if (@same_fingerings[0][:approved] == false)
        msg = 'has already been entered and is currently pending approval.'
      else
        msg = 'already exists (please see fingering ID #' + @same_fingerings[0][:id].to_s + ').'
      end
      redirect_to fingerings_url, :notice => 'The ' + @same_fingerings[0].pretty_notes + ' fingering you just entered was not submitted because it ' + msg and return
    end

    @fingering = Fingering.create!(params[:fingering])
    @fingering.votes_beginner     = 0
    @fingering.votes_intermediate = 0
    @fingering.votes_advanced     = 0
    @fingering.votes_professional = 0
    @fingering.dvotes_beginner     = 0
    @fingering.dvotes_intermediate = 0
    @fingering.dvotes_advanced     = 0
    @fingering.dvotes_professional = 0
    @fingering.user_name = current_user.login

    if current_user.isAdmin
      @fingering.admin_order = params[:fingering][:admin_order]
      updateFingeringOrdersOnNewOrDelete(@fingering.id, @fingering.note_tone, params[:fingering][:admin_order], false)
    else
      #this fingering has been added to database and will be counted in count (that is why we don't do count() + 1)
      @fingering.admin_order = count_fingerings(@fingering.note_tone)
    end

    if(!current_user.isAdmin)
        @fingering.approved  = false
    else
	      @fingering.approved = true
    end
    
    @fingering.score = 0

    @origString = @fingering.note_tone
    @accidental = @origString.split('_')[1]
    @accidental = @accidental.split(',')[0] # only look at first note if multiple
    @octave = @origString[3]
    @note_name = @origString[2]
    if @accidental == "flat"
      @fingering.accidental = 1
    elsif @accidental == "natural"
      @fingering.accidental = 2
    else
      @fingering.accidental = 3
    end
    @fingering.octave = @octave
    @fingering.note_name = @note_name

    if @fingering.save
      if (!current_user.isAdmin)
        msg = 'submitted for approval.'
        @fingering.send_fingering_submitted #send email to admins if regular user submits a new fingering
      else
        msg = 'created.'
      end
      redirect_to fingerings_url, :notice => 'The ' + @fingering.pretty_notes + ' (ID #' + @fingering.id.to_s + ') fingering was successfully ' + msg
    else
      render action: "new"
    end
  end

  def edit
    @fingering        = Fingering.find(params[:id])
    @fingering_status = @fingering.fingering_status
    @note_tone        = @fingering.note_tone
    @octave = @fingering.octave
    @note_name = @fingering.note_name
    @accidental = @fingering.accidental
  end

  def update
    @fingering = Fingering.find(params[:id])

    @old_admin_order = @fingering.admin_order

    if(!current_user.isAdmin)
	    @fingering.approved = false
      @fingering.send_fingering_submitted
    end

    if @fingering.update_attributes(params[:fingering])
      if !current_user.isAdmin
        msg = 'Fingering was successfully updated, and has been resubmitted for approval.'
      else
        msg = 'Fingering was successfully updated.'
      end

      if (current_user.isAdmin && @old_admin_order != params[:fingering][:admin_order])
        updateFingeringOrdersOnEdit(params[:id], params[:fingering][:note_tone], @old_admin_order, params[:fingering][:admin_order], false)
      end

      redirect_to @fingering, :notice => msg
    else
      render action: "edit"
    end
  end

  #id is the id of the fingering with order admin_order
  #note_tone is the note_tone of the fingering with the given id
  def updateFingeringOrdersOnEdit(id, note_tone, old_admin_order, admin_order, fingering_deleted)
    #make sure admin_order is an integer so our comparisons won't fail in the for loop
    if (!admin_order.is_a? Integer)
      admin_order = admin_order.to_i
    end

    #make sure old admin order is an integer
    if (!old_admin_order.is_a? Integer)
      old_admin_order = old_admin_order.to_i
    end    

    if (old_admin_order > admin_order)
      #get all fingerings with same note_tone or enharmonic equivalent (excluded the fingering with an ID# == id) and with an admin order that needs updated
      @same_note_fingerings = Fingering.where('id != ?', id).where('note_tone = ? OR note_tone = ?', note_tone, getEnharmonicEquivalent(note_tone)).where('admin_order < ? AND admin_order >= ?', old_admin_order, admin_order)
   
      if (@same_note_fingerings != nil && @same_note_fingerings.size > 0)
        for i in 0..(@same_note_fingerings.size - 1)
          #increment admin order
          @same_note_fingerings[i][:admin_order] = @same_note_fingerings[i][:admin_order] + 1
          @same_note_fingerings[i].save
        end
      end
    elsif (old_admin_order < admin_order) #old_admin_order will not equal admin_order since we check this before calling the function
      #get all fingerings with same note_tone or enharmonic equivalent (excluded the fingering with an ID# == id) and with an admin order that needs updated
      @same_note_fingerings = Fingering.where('id != ?', id).where('note_tone = ? OR note_tone = ?', note_tone, getEnharmonicEquivalent(note_tone)).where('admin_order > ? AND admin_order <= ?', old_admin_order, admin_order)

      if (@same_note_fingerings != nil && @same_note_fingerings.size > 0)
        for i in 0..(@same_note_fingerings.size - 1)
          #decrement admin order
          @same_note_fingerings[i][:admin_order] = @same_note_fingerings[i][:admin_order] - 1
          @same_note_fingerings[i].save
        end
      end
    end
  end

  def updateFingeringOrdersOnNewOrDelete(id, note_tone, admin_order, onDelete)
    #make sure admin_order is an integer so our comparisons won't fail in the for loop
    if (!admin_order.is_a? Integer)
      admin_order = admin_order.to_i
    end
    
    #get all fingerings with same note_tone or enharmonic equivalent (excluded the fingering with an ID# == id) and with an admin order that needs updated
    @same_note_fingerings = Fingering.where('id != ?', id).where('note_tone = ? OR note_tone = ?', note_tone, getEnharmonicEquivalent(note_tone)).where('admin_order >= ?', admin_order)  
    
    if (@same_note_fingerings != nil && @same_note_fingerings.size > 0)
      if (onDelete)
        #decrement admin orders
        for i in 0..(@same_note_fingerings.size - 1)
          @same_note_fingerings[i][:admin_order] = @same_note_fingerings[i][:admin_order] - 1
          @same_note_fingerings[i].save
        end
      else  
        #increment admin orders
        for i in 0..(@same_note_fingerings.size - 1)
          @same_note_fingerings[i][:admin_order] = @same_note_fingerings[i][:admin_order] + 1
          @same_note_fingerings[i].save
        end
      end
    end

  end

  def destroy
    @fingering = Fingering.find(params[:id])

    updateFingeringOrdersOnNewOrDelete(params[:id], @fingering.note_tone, @fingering.admin_order, true)
    @pretty_notes = @fingering.pretty_notes
    @fingering.destroy

    redirect_to fingerings_url, :notice => @pretty_notes + " fingering (ID #" + params[:id].to_s + ") deleted."
  end
  
  def approve
    if params[:save_first] != nil && params[:save_first] == "on"
      saveIndividualFingeringFromTrill("first", true)
    end

    if params[:save_second] != nil && params[:save_second] == "on"
      saveIndividualFingeringFromTrill("second", true)
    end

    @fingering = Fingering.find(params[:id])
    
    @fingering.approved = !@fingering.approved
    
    if @fingering.update_attributes(params[:fingering])
      redirect_to @fingering, :notice => "Fingering was approved."
    else
      redirect_to @fingering, :notice => "Fingering approval failed."
    end
  end
  
  def reset_votes
    @fingering = Fingering.find(params[:id])
 
    @fingering.votes_professional = 0
    @fingering.votes_advanced = 0
    @fingering.votes_intermediate = 0
    @fingering.votes_beginner = 0
    @fingering.dvotes_professional = 0
    @fingering.dvotes_advanced = 0
    @fingering.dvotes_intermediate = 0
    @fingering.dvotes_beginner = 0
   
    if @fingering.save
      redirect_to @fingering, :notice => "Fingering votes were reset."
    else
      redirect_to @fingering, :notice => "Fingering votes failed to be reset."
    end
  end
  
  def like
    @fingering = Fingering.find(params[:id])

    if @fingering.votes_professional == nil
      @fingering.votes_professional = 0
    end
    
    if @fingering.votes_advanced == nil
      @fingering.votes_advanced = 0
    end
      
    if @fingering.votes_intermediate == nil
      @fingering.votes_intermediate = 0
    end
      
    if @fingering.votes_beginner == nil
      @fingering.votes_beginner = 0
    end
    
    if current_user.skill == "professional"
      @fingering.votes_professional += 1
    elsif current_user.skill == "advanced"
      @fingering.votes_advanced += 1
    elsif current_user.skill == "intermediate"
      @fingering.votes_intermediate += 1
    else
      @fingering.votes_beginner += 1
    end
    
    if @fingering.save
      if cookies[:votes] != nil and cookies[:votes_user] != nil
        @votes = Array.new()
        @votes = cookies[:votes]
        @votes << @fingering.id.to_s()
        cookies[:votes] = @votes
        
        @voters = Array.new()
        @voters = cookies[:votes_user]
        @voters << current_user.login
        cookies[:votes_user] = @voters 
      else 
        cookies[:votes] = @fingering.id.to_s()
        cookies[:votes_user] = current_user.login
      end
      @fingering.score = self.rating # re-rate the fingering every time it is liked or disliked
      @fingering.save
      redirect_to @fingering, :notice => "Fingering was liked."
    else 
      redirect_to @fingering, :notice => "Fingering was not liked."
    end
  end
  
  def dislike
    @fingering = Fingering.find(params[:id])
    
    if @fingering.dvotes_professional == nil
      @fingering.dvotes_professional = 0
    end
    
    if @fingering.dvotes_advanced == nil
      @fingering.dvotes_advanced = 0
    end
      
    if @fingering.dvotes_intermediate == nil
      @fingering.dvotes_intermediate = 0
    end
      
    if @fingering.dvotes_beginner == nil
      @fingering.dvotes_beginner = 0
    end
    
    if current_user.skill == "professional" 
      @fingering.dvotes_professional += 1
    elsif current_user.skill == "advanced"
      @fingering.dvotes_advanced += 1
    elsif current_user.skill == "intermediate"
      @fingering.dvotes_intermediate += 1
    else
      @fingering.dvotes_beginner += 1
    end
    
    if @fingering.save
      if cookies[:votes] != nil and cookies[:votes_user] != nil
        @votes = Array.new()
        @votes = cookies[:votes]
        @votes << @fingering.id.to_s()
        cookies[:votes] = @votes
        
        @voters = Array.new()
        @voters = cookies[:votes_user]
        @voters << current_user.login
        cookies[:votes_user] = @voters 
      else 
        cookies[:votes] = @fingering.id.to_s()
        cookies[:votes_user] = current_user.login
      end
      @fingering.score = self.rating # re-rate the fingering every time it is liked or disliked
      @fingering.save
      redirect_to @fingering, :notice => "Fingering was disliked."
    else 
      redirect_to @fingering, :notice => "Fingering was not disliked."
    end
  end
  
  def rating
    likes = @fingering.votes_professional + @fingering.votes_advanced + @fingering.votes_intermediate + @fingering.votes_beginner
    dislikes = @fingering.dvotes_professional + @fingering.dvotes_advanced + @fingering.dvotes_intermediate + @fingering.dvotes_beginner
    total = likes + dislikes
    if total == 0
      return 0
    end
    z = 1.96 # z-score for 95% CI
    phat = 1.0*likes/total
    return ( phat + (z*z) / (2*total) - z * Math.sqrt( (phat * (1-phat) + z*z/(4*total) ) / total) )/ ((1+(z*z))/total )
    
  end
  
  
end
