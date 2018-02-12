# -*- encoding : utf-8 -*-

class RakeProgressbar
  attr_accessor :maximal, :actual, :cols, :finish, :started, :percent, :last_percent, :last_time_dif

  def initialize(maximal)
    if maximal.nil? || maximal < 1
      return nil
    else
      self.maximal = maximal
      self.started = Time.now
      self.actual = -1
      self.last_percent = -1
      self.cols = detect_terminal_size[0] - 3 if detect_terminal_size
      self.cols = 80 if self.cols.nil? || self.cols < 80
      self.finish = false
      if maximal == 0
        puts "nothing to do"
      else
        inc
      end
      return self
    end
  end

  def inc
    self.actual += 1
    self.percent = (self.actual.to_f/self.maximal.to_f*100.0)
    
    display
    
    if self.actual == self.maximal && !self.finish
      finished
    end
  end

  def display
    time_dif = ((Time.now - self.started)).to_i
    if self.percent == 0
      remaining = 0
    else
      remaining = (time_dif.to_f/self.percent.to_f * 100.0).to_i - time_dif
    end
    
    if self.last_percent != (self.percent*10).to_i && self.last_time_dif != time_dif
      percent_out = ((self.percent*10).to_i.to_f/10.0).to_s
      if percent < 10
        percent_out = "  "+percent_out
      elsif percent < 100
        percent_out = " "+percent_out
      end
      STDOUT.print("\r#{percent_out}% ")
      STDOUT.print( "["+("#" * (self.percent*((self.cols-31).to_f/100)).to_i))
      STDOUT.print( ("_")* ((100-self.percent)*((self.cols-31).to_f/100)).to_i)
      STDOUT.print( "] "+(Time.at(remaining).utc.strftime('%H:%M:%S')) )
      STDOUT.print( (" -> ")+(Time.at(time_dif).utc.strftime('%H:%M:%S'))+" " )
      STDOUT.flush
      self.last_percent = (self.percent*10).to_i
      self.last_time_dif = time_dif
    end
  end

  def finished(show_actual = false)
    if self.finish == false
      self.last_percent = 990
      self.last_time_dif = -1
      self.percent = 100.0
      if self.maximal != 0
        display
      end
      STDOUT.print "\n"
      if show_actual
        STDOUT.print "Finished #{self.actual} in #{Time.now - self.started}s\n"
      else
        STDOUT.print "Finished in #{Time.now - self.started}s\n"
      end
      STDOUT.flush
      self.finish = true
    end
  end
  
  
  # Determines if a shell command exists by searching for it in ENV['PATH'].
  def command_exists?(command)
    ENV['PATH'].split(File::PATH_SEPARATOR).any? {|d| File.exists? File.join(d, command) }
  end

  # Returns [width, height] of terminal when detected, nil if not detected.
  # Think of this as a simpler version of Highline's Highline::SystemExtensions.terminal_size()
  def detect_terminal_size
    if (ENV['COLUMNS'] =~ /^\d+$/) && (ENV['LINES'] =~ /^\d+$/)
      [ENV['COLUMNS'].to_i, ENV['LINES'].to_i]
    elsif (RUBY_PLATFORM =~ /java/ || (!STDIN.tty? && ENV['TERM'])) && command_exists?('tput')
      [`tput cols`.to_i, `tput lines`.to_i]
    elsif STDIN.tty? && command_exists?('stty')
      `stty size`.scan(/\d+/).map { |s| s.to_i }.reverse
    else
      nil
    end
  rescue
    nil
  end
end