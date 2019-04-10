#===============================================================================================================================
# !!!   QuickControls.rb  |  A control scheme manager wrapped for use inside of $program when running.
#-----------------------------------------------------------------------------------------------------------------------------
# By: Wiggles
# Version 0.8
# Date: 2/20/19
#===============================================================================================================================
module QuickControls
=begin
  User defined input mappings and current button/key states for Input related statments.
--------------------------------------       --------------------------------------       --------------------------------------
		 Avaliable Control Schemes:                         |     Tack Buttons: *For an xbox 360 Controler*     
  --------------------------------------                |                             
		   Menu Navigation                                  |                             
        :menu_up                                        |                 gp_0  = A
        :menu_down                                      |                 gp_1  = B
        :menu_left                                      |                 gp_2  = X
        :menu_right                                     |                 gp_3  = Y
        :menu_scroll_up                                 |                 gp_cl = Back
        :menu_scroll_down                               |                 gp_cm = XBOX button
        :menu_action                                    |                 gp_cr = Start
  --------------------------------------                |                 gp_lbump = LB
      Player Controls  	                                |                 gp_rbump = RB
        :move_up                                        |                 gp_ltrigger = LT
        :move_down                                      |                 gp_rtrigger = RT
        :move_left                                      |                 gp_ls_click = LStick clicked down
        :move_right                                     |                 gp_rs_click = RStick clicked down
        :move_jump                                      |                 
        :move_sprint                                    |                 
        :attack_one                                     |                 
        :pause_menu                                     |                 
  --------------------------------------                |            Digital Pad and Joy Stick:
		  Misc Standards                                    |                     gp_down
        :action_key                                     |                     gp_up
        :mouse_lclick                                   |                     gp_left
        :mouse_rclick                                   |                     gp_right
        :cancel_action                                  |          **  Does ALL anolog stick input **
        :debug_action_one                               |                      
        :debug_action_two                               |

--------------------------------------       --------------------------------------       --------------------------------------
Basic Use:
   $program.holding?(:move_left)    -=- Check to see if any input key used for player movement to the left has been triggered.   
   $program.trigger?(:mouse_lclick) -=- Check to see if a key/button trigger was depresed responsable for mouse clicking.
		*( Will only use a :symbol from the @@Controls table )*
					   --------------------------------------   
Advanced Use:
	$program.holding?(:left , true)     -=- Check single button value for depression. Uses symbol to check if that button is being held down.
	$program.trigger?(:l_clk, true)     -=- Check single button value for trigger, was or is being depressed but was only triggered once.
		*( Can use any Gosu or @@table button :symbol )*
					   --------------------------------------   
					   
To make changes the Control Scheme table you can use:
   $program.Controls[:Scheme_Name].push(:New_Key)           -=- Adds a new button to control scheme.
   $program.Controls[:Scheme_Name].delete(:Removed_Key)     -=- Removes button from control scheme.
   
Changing schemes:
   $program.Controls.delete(:Remove_Scheme)     -=- Removes control shceme from mapping.
   $program.Controls[:New_Scheme] = [:buttons]  -=- Creates a new control scheme for mapping.
--------------------------------------       --------------------------------------       --------------------------------------
Most of the game input is wrapped into Gosu::Window dues to the way Gosu recives calls back a button key input it will pass it 
  to Program ( $program ) class by the use of:
	 
   + virtual void button_down(Gosu::Button) {}  +  Which is handed off to the same $program function name.
 The above function is called before update when the user pressed a button while the window had the focus.
		  
   + virtual void button_up(Gosu::Button) {}    +  Which is handed off to the same $program function name.
 Same as the above for button_down, but instead called when the user has released a button.
 
This and more information on Gosu C Headers can be found here:  https://www.libgosu.org/cpp/namespace_gosu.html  
=end
#===============================================================================================================================
  INPUT_LAG = 1 # Time to wait in between @buttons_down clearing. (* Mouse wheel buttons have trouble when set to 0 *)
  #---------------------------------------------------------------------------------------------------------
  #D: Create the container classes for use with in the scheme manager.
  #---------------------------------------------------------------------------------------------------------
  def controls_init
    @buttons_down = [] #DV All buttons currently being held down.
    @buttons_up   = [] #DV Any button that was recently held down, but was released.
    @triggered    = [] #DV Buttons depressed that do not count as being depressed when they are held down.
    @triggers     = [] #DV Used together with @triggered to keep track of keys once.
    @holding      = [] #DV Any button that is currently being held down.
    @input_lag  = 0 #DV Mouse wheel has trouble, catches too many inputs.
    @input_wait = 0 #DV Time between text return for string functions.
    # build the controls for the first time.
    map_table; reset_input_defualts
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Reset the control scheme back to default.
  #---------------------------------------------------------------------------------------------------------
  def reset_input_defualts
    @Controls = Konfigure::DEFAULT_CONTROLS #DV Hash container for the current control scheme.
  end
  #---------------------------------------------------------------------------------------------------------------------
  #D Table of mapped inputs for a US Qwerty keyboard, A standard mouse, and an Xbox Controller in windows at least...
  #---------------------------------------------------------------------------------------------------------------------
   def map_table
    @table = { # US keyboad 0x00000409 mappings; additional INFO: https://en.wikipedia.org/wiki/Keyboard_layout
      # Identifiers: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-language-pack-default-values
      :right       =>  79, :left        =>  80, :down     =>  81, :up       =>  82, :period    =>  55, :question   =>  56,
      :collon      =>  51, :equils      =>  46, :comma    =>  54, :dash     =>  45, :tiddle    =>  53, :fslash     =>  49, 
      :openbracket =>  47, :closebraket =>  48, :quote    =>  48, :lshift   => 225, :rshift    => 229, :pause      =>  72,
      :l_clk       => 256, :m_clk       => 257, :r_clk    => 258, :mouse_wu => 259, :mouse_wd  => 260,
      :return      =>  40, :backspace   =>  42, :space    =>  44, :esc      =>  41, :tab       =>  43,
      :rctrl       => 228, :lalt        => 226, :ralt     => 230, :lctrl    => 224,
      #--------------------------------------
      :end        =>  77, :home        =>  74, :ins         =>  73, :del      =>  76, :lwinkey   => 227, :rwinkey  => 231,
      :capslock   =>  57, :scrolllock  =>  71, :numlock     =>  83, :pageup   =>  75, :pagedwn   =>  78, 
      :p_enter    =>  88, :padadd      =>  87, :padsub      =>  86, :padmulti =>  85, :paddivide =>  84,
      :vol_down   => 129, :vol_up      => 128, :printscreen =>  70, :taskkey  => 101, :pdecimal  =>  99,
      #--------------------------------------
      :gp_ls_click => 304, :gp_rs_click => 305,  # AS well...  :gp_ls_click => 284, :gp_rs_click => 285
      :gp_ls_left => 293, :gp_ls_right => 294, :gp_ls_up => 295, :gp_ls_down => 296,
      :gp_rs_left => 273, :gp_rs_right => 274, :gp_rs_up => 275, :gp_rs_down => 276,
      # Same as left stick (pg_ls_) Gosu ties all sticks together. I.E. both ls and rs are input at the same time as another.
      :gp_up => 295, :gp_down => 296, :gp_left => 293, :gp_right => 294,
      #--------------------------------------
      :gp_rtrigger => 289, :gp_ltrigger => 288, :gp_rbump => 287, :gp_lbump => 286,
      :gp_0 => 297, :gp_1 => 298, :gp_2 => 299, :gp_3 => 300, # AS well...  :gp_0 => 277, :gp_1 => 278, :gp_2 => 279, :gp_3 => 280
      :gp_cl => 301, :gp_cm => 302, :gp_cr => 303, # AS well...  :gp_cl => 281, :gp_cm => 282, :gp_cr => 283
    }
    #--------------------------------------
    id = 0; temp = {} # ID of the key and temp working container.
    #--------------------------------------
    # Add all the letter keys on the keyboard.
    for l in "a".."z"; temp.store("let_#{l}".to_sym, 4 + id); id += 1; end; id = 0; @table.update(temp); temp = {} 
    #--------------------------------------
    # Add all of the number keys of the keyboard.
    for n in "1".."9"; temp.store("num_#{n}".to_sym, 30 + id); id += 1; end; id = 0; temp.store("num_0".to_sym, 39)
    @table.update(temp); temp = {} 
    #--------------------------------------
    # Add the Key pad numbers.
    for n in "1".."9"; temp.store("pad_#{n}".to_sym, 89 + id); id += 1; end; id = 0; temp.store("pad_0".to_sym, 98)
    @table.update(temp); temp = {}
    #--------------------------------------
    # Add all of the F-keys.
    for n in "1".."12"; temp.store("f_#{n}".to_sym,  58 + id); id += 1; end; @table.update(temp); temp = {}
    #--------------------------------------
    id = temp = nil # clear temp variables.
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Called from Gosu::Window.update tick to keep up with control input changes.
  #---------------------------------------------------------------------------------------------------------
  def input_update
    #--------------------------------------
    # general button input updating, this needs to be initialized in a timely mater,
    # which is why it's object is created here in update
    #print_input_keys if @PRINT_INPUT_KEY
    #--------------------------------------
    # prevent same character but diffrent case on shift usage for input return
    unless self.holding?(:shift)
      @input_wait -= 1 if @input_wait > 0
    end
    # sometimes keys are depressed and released very quickly (i.e. Mouse Wheel functions) and need extra time to register amongst classes.
    if @input_lag > 0
      @input_lag -= 1
    else
      #--------------------------------------
      # update input array of buttons being held down.
      @buttons_down = @buttons_down - @buttons_up # remove buttons held down if they where released.
      # add any key triggers to class @triggered at the same time so each class using trigger? get a chance to check shared input keys
      @triggered = @triggered + @triggers
      @triggers = []
      # clear any triggers when the key that was triggered is released
      @buttons_up.each { |id|
        if @triggered.include?(id)
          @triggered.delete(id)
        end
      }
      @buttons_up = [] # will hold onto all recent button releases unless cleared.
    end
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Returns the symbol attached to the key id.
  #---------------------------------------------------------------------------------------------------------
  def get_input_symbol(id)
    return @table.key(id)
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Returns the id attached to the key symbol.
  #---------------------------------------------------------------------------------------------------------
  def get_input_id(symbol)
    #puts "#{symbol}"
    return @table[symbol]
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Prints the current keyboard/game-pad input symbol and value to console.
  #---------------------------------------------------------------------------------------------------------
  def print_input_keys
    #return if $program.nil?
    butt_id = self.get_input_key 
    #print("#{$program.input}\n"); exit # display current keys mapped to methods for the $program class
    return if butt_id.nil? or @prevously_pressed_key == butt_id
    @prevously_pressed_key = butt_id
    #print("(#{@table.key(butt_id)}) for Win32API/n")
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Return character key of current input, this is used for text input fields generally.
  #---------------------------------------------------------------------------------------------------------
  def grab_characters
    key = '' # string value of input key
    shifting = self.holding?(:shift)
    @@buttons_down.each do |butt_id|
      return '' if @input_wait > 0 and !shifting
      butt_chr = @@table.key(butt_id).to_s
      #--------------------------------------
      # letters
      if butt_chr.include?("let_")
        key = butt_chr.sub!('let_', '')
        if shifting # capital letter?
          @input_wait = 5
          key.capitalize!
        end
      #--------------------------------------
      # numbers
      elsif butt_chr.to_s.include?("num_")
        key = butt_chr.sub!('num_', '')
        if shifting # special char?
          case key
          when '1' then key = '!'
          when '2' then key = '@' 
          when '3' then key = '#'
          when '4' then key = '$' 
          when '5' then key = '%'
          when '6' then key = '^'
          when '7' then key = '&'
          when '8' then key = '*'
          when '9' then key = '('
          when '0' then key = ')'
          end
          @input_wait = 5
        end
      elsif butt_chr.to_s.include?("pad_")
        key = butt_chr.sub!('pad_', '')
      #--------------------------------------
      # functions
      elsif %w[backspace return del space tab].include?(butt_chr.to_s)
        key = butt_chr.to_s
      #--------------------------------------
      # anything else
      else
        case butt_chr
        when 'comma'  then key = ','
        when 'period' then key = '.'
        else
          #puts("There is an unknown character being depressed! (#{butt_id})")
        end
      end
    end
    return key
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Check to see if (key_symbol = :button_symbol , id_only = true) or (key_symbol = @Controls[:symbol]) is currently being held down.
  #---------------------------------------------------------------------------------------------------------
  def holding?(key_symbol, id_only = false)
    assigned_buttons = @Controls[key_symbol] unless id_only # using localized key mapping
    if assigned_buttons.nil?
      unless key_symbol.is_a?(Array)
        assigned_buttons = [key_symbol]
      end
    end
    #--------------------------------------
    input = false
    for button in assigned_buttons
      input |= @buttons_down.include?(@table[button]) # check to make sure no buttons via call back are depressed
      break if input
    end
    return input # return value of button(s) state
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Check to see if (key_symbol = :button_symbol , id_only = true) or (key_symbol = @Controls[:symbol])
  #D: was depressed, count it once and remove from input.
  #---------------------------------------------------------------------------------------------------------
  def trigger?(key_symbol, id_only = false)
    assigned_buttons = @Controls[key_symbol] unless id_only # using localized key mapping
    if assigned_buttons.nil?
      unless key_symbol.is_a?(Array)
        assigned_buttons = [key_symbol]
      end
    end
    #--------------------------------------
    for button in assigned_buttons
      #puts "Control settings for (#{key_symbol}) - #{button} = #{@buttons_down}"
      if @buttons_down.include?(@table[button])
        #print("checking input trigger for #{key_symbol} butt:(#{button})\n")
        unless @triggered.include?(@table[button])
          @triggers << @table[button]
          #puts ("(#{key_symbol}) Button was triggered (#{@triggered})")if input # print all current triggered keys
          return true
        end
      end
    end
    #--------------------------------------
    return false 
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Check and return input registers to game pad 0 joystick left. *Gosu for some reason joins with right stick.
  #---------------------------------------------------------------------------------------------------------
  def left_joy_stick
    # [up, down, left, right]
    directions = [false, false, false, false]
    if self.button_down?(295)    # stick up
      directions[0] = true
    elsif self.button_down?(296) # stick down
      directions[1] = true
    elsif self.button_down?(293) # stick left
      directions[2] = true
    elsif self.button_down?(294) # stick right
      directions[3] = true
    end
    return directions
  end
  #---------------------------------------------------------------------------------------------------------
  #D:Check and return input registers to game pad 0 joystick right. *Gosu for some reason joins with left stick.
  #---------------------------------------------------------------------------------------------------------
  def right_joy_stick
    # [up, down, left, right]
    directions = [false, false, false, false]
    if self.button_down?(275)    # stick up
      directions[0] = true
    elsif self.button_down?(276) # stick down
      directions[1] = true
    elsif self.button_down?(273) # stick left
      directions[2] = true
    elsif self.button_down?(274) # stick right
      directions[3] = true
    end
    return directions
  end
end

#===============================================================================================================================
# This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either Version 3 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free 
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#===============================================================================================================================
