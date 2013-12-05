#encoding: utf-8

class Fingering < ActiveRecord::Base
  validates_length_of   :fingering_status, :minimum => 32
  validates_length_of   :note_tone, :minimum => 4
  validates_presence_of :note_tone, :fingering_status, :keytype
  #validates_format_of   :fingering_status, :with => regEx?, :message => "Fingering Status String Incorrect"
  #validates_format_of   :note_tone, :with => regEx?, :message => "Note Tone String Incorrect"
  
  def pretty_notes
    n     = self.note_tone[0].to_i
    notes = Array.new(n)
    tones = Array.new(n)
    
    # Parse Notes
    temp = Array.new(n);
    temp = self.note_tone[2..-1].split(',')

    for i in 0..(n - 1)
      notes[i] = temp[i][0..1]
    end
   
    # Parse Tones
    temp = Array.new(n); 
    temp = self.note_tone[2..-1].split(',');

    for i in 0..(n - 1)
      if temp[i][3..-1] == "natural"
        tones[i] = "♮"
      elsif temp[i][3..-1] == "flat"
        tones[i] = "♭"
      elsif temp[i][3..-1] == "sharp"
        tones[i] = "♯"
      end
    end

    # Pretify
    ret = (n == 1)?(tones[0] + notes[0]):(tones[0] + notes[0] + ' to ')
    for i in 1..n - 1
      ret = (i + 1 >= n)?(ret + tones[i] + notes[i]):(ret + tones[i] + notes[i] + ' to ')
    end

    return ret
  end

  def enharmonic_pretty_notes
    @enharmonic = ""

    if (self.note_tone[0] = "1")
      @origString = self.note_tone
      @accidental = @origString.split('_')[1]
      @accidental = @accidental.split(',')[0] # only look at first note if multiple
      @octave = @origString[3]
      @note_name = @origString[2]
     
      if (@accidental == "sharp")
        if (@note_name == "a")
          @enharmonic = "1:b" + @octave + "_flat"
        elsif (@note_name == "c")
          @enharmonic = "1:d" + @octave + "_flat"
        elsif (@note_name == "d")
          @enharmonic = "1:e" + @octave + "_flat"
        elsif (@note_name == "f")
          @enharmonic = "1:g" + @octave + "_flat"
        elsif (@note_name == "g")
          @enharmonic = "1:a" + @octave + "_flat"
        end
      elsif (@accidental == "flat")
        if (@note_name == "b")
          @enharmonic = "1:a" + @octave + "_sharp"
        elsif (@note_name == "d")
          @enharmonic = "1:c" + @octave + "_sharp"
        elsif (@note_name == "e")
          @enharmonic = "1:d" + @octave + "_sharp"
        elsif (@note_name == "g")
          @enharmonic = "1:f" + @octave + "_sharp"
        elsif (@note_name == "a")
          @enharmonic = "1:g" + @octave + "_sharp"
        end
      end
    end

    if (@enharmonic != "")
      @save_note_tone = self.note_tone
      self.note_tone = @enharmonic
      @enharmonic_pretty = self.pretty_notes
      self.note_tone = @save_note_tone
      return @enharmonic_pretty
    else
      return @enharmonic
    end

  end
  def send_fingering_submitted
    @admins = User.where(admin: true);
    @admins.each do |admin|
      FingeringMailer.fingering_submitted_email(self, admin).deliver 
    end
  end
end
