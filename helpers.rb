class Array
  def has?(tag)
    self.collect { |x| x.match(tag) }.compact.length > 0
  end
end

class Array
  def only_packages
    # self.select { |x| x['labels'].map(&:name).has?(ENV['HEYTHERE_LABEL_TARGET']) }
    self.select { |x| x['labels'].map(&:name).has?(Heythere.label_target) }
  end
end

class Array
  def revs_assigned
    x = self.select{ |x| !!x.match(/[0-9]/) }
    if x.length > 0
      x.collect { |x| x.split('/')[0].to_i >= 3 }.any?
    else
      return false
    end
  end
end

class Array
  def rev_in
    x = self.select{ |x| !!x.match(/[0-9]/) }
    if x.length > 0
      x.collect { |x| x.split('/')[0].to_i >= 4 }.any?
    else
      return false
    end
  end
end

class Hash
  def get_info
    vars = [:url, :number, :title]
    tmp = self.select { |k,_| vars.include?(k) }
    tmp[:user] = self[:user][:login]
    return tmp
  end
end

def days_since(x)
  return (Date.parse(Time.now.getutc.to_s) - Date.parse(x.to_s)).to_f.floor
end

def days_plus_day(x)
  return Date.parse((Time.now + x.days).to_s).strftime("%b %d")
end

class Fixnum
  def days
    self * 86400
  end
end

def revs_not_reviewed(x, y)
  revsret = y[0][:body].match(/Reviewers:/).post_match
  # clean out due date, if exists
  revsret = revsret.sub(/due.+/im, '')
  revs = revsret.sub(',', '').strip.gsub('@', '').sub(' ', '|')
  revs = revs.sub(/\n.+|\r.+/, '').sub(/\s/, '').sub(/\r/, '')
  comms = x.select { |z| z[:user][:login].match(/#{revs}/) }
  longcomms = comms.select { |y| y[:body].length > 1300 }
  lclogins = longcomms.map(&:user).map(&:login)
  if lclogins.length > 0
    left = revs.gsub(/#{lclogins.join('|')}|\|/, '')
    if left.length == 0
      return nil
    else
      return ['@' + left]
    end
  else
    return revsret.sub(',', '').strip.split(/[\s]/)
  end
end

def already_pinged_within_days(x, days, mssg)
  x = x.select { |w| ( Date.parse(Time.now.getutc.to_s) - Date.parse(w['created_at'].to_s) ) <= days.to_i }
  res = x.map(&:body).select { |w| w.match(/#{mssg}/) }
  return res.length != 0
end
