require 'json'
require 'time'
require 'set'

class Issues
  def initialize(issues_path)
    @issues = JSON.parse(IO.read(issues_path)).map{|hash| Issue.new(hash)}
    @labels = fetch_labels_from_issues()
  end

  def fetch_labels_from_issues
    labels = Set[]
    @issues.each do |issue|
      labels.merge(issue.labels)
    end
    labels.to_a
  end

  def timeline
    timeline = []
    timestamps.each do |timestamp|
      status_counter = {unborn: 0, open: 0, closed: 0}
      active_counter = {dontcare: 0, active: 0, stale: 0}
      label_counter = {}
      @labels.each do |label|
        label_counter[label] = 0
      end

      # Calculate a lead time sample for issues closed at this timestamp
      lead_time_issues = []
      @issues.each do |issue|
        status = issue.status(timestamp)
        status_counter[status] += 1
        if status == :open
          active_counter[issue.is_stale] += 1
          issue.labels.each do |label|
            label_counter[label] += 1
          end
        end
        if issue.closed_at == timestamp
          lead_time_issues << issue
        end
      end
      if lead_time_issues.any?
        lead_time_sum = lead_time_issues.map(&:lead_time).inject(0.0) { |sum, lt| sum + lt}
        lead_time_sample = lead_time_sum / lead_time_issues.size
        status_counter[:lead_time_sample] = lead_time_sample
        status_counter[:closed_issues] = lead_time_issues.map(&:number).join(',')
      end

      entry = [timestamp, status_counter.dup, active_counter.dup, label_counter.dup]
      timeline << entry

      time_where_total_count_like_closed = nil
      timeline.each do |past|
        total_count = past[1][:open] +  past[1][:closed]
        if total_count >= status_counter[:closed]
          time_where_total_count_like_closed = past[0]
          break
        end
      end
      lead_time = (timestamp - time_where_total_count_like_closed)
      entry[1][:lead_time] = lead_time
    end

    timeline
  end

  def timestamps
    @timestamps ||= @issues.map {|i| [i.created_at, i.closed_at]}.flatten.compact.sort.uniq
  end

  def labels
    @labels
  end
end

class Issue
  def initialize(hash)
    @hash = hash
  end

  def created_at
    @created_at ||= Time.parse(@hash['created_at'])
  end

  def closed_at
    @closed_at ||= @hash['closed_at'].nil? ? nil : Time.parse(@hash['closed_at'])
  end

  def number
    @hash['number']
  end

  def lead_time
    @closed_at ? closed_at - created_at : nil
  end

  def is_stale
    return :active if @hash['assignee']
    return :stale
  end

  def status(timestamp)
    return :unborn if timestamp < created_at
    return :closed if closed_at && (closed_at < timestamp)
    return :open
  end

  def labels
    labels = Set[]
    label_hashes = @hash['labels']
    label_hashes.each do |label_hash|
      labels.add(Lable.new(label_hash))
    end
    labels
  end
end

class Lable
  def initialize(hash)
    @id = hash['id']
    @name = hash['name']
    @color = hash['color']
  end

  def eql?(other)
    if other.respond_to?(:id)
      return self.id == other.id
    end
  end

  def id
    return @id
  end

  def name
    return @name
  end

  def color
    return @color
  end

  def hash
    return @id.hash
  end
end
