require 'uri'
require 'net/http'
require 'json'

class Line
  attr_accessor :name, :statuses

  def initialize(name, statuses)
    @name = name
    @statuses = statuses
  end

  def status
    return @statuses.map { |s| s.description }.join(", ")
  end

  def is_good_service?
    return @statuses.any? { |s| s.is_good_service? }
  end
end

class LineStatus

  attr_accessor :severity_code, :description

  def initialize(severity_code, description)
    @severity_code = severity_code
    @description = description
  end

  def is_good_service?
    return @severity_code == 10
  end
end

uri = URI('https://api.tfl.gov.uk/Line/Mode/tube/Status')
res = Net::HTTP.get_response(uri)

if res.is_a?(Net::HTTPSuccess) 
  JSON.parse(res.body).map { |line|
    # concatenated_statuses = line["lineStatuses"].map{ |status| status["statusSeverityDescription"] }.join(", ")
    # puts "\u001b[32m\u2713\u001b[0m  #{line["name"]}\t\u001b[32m[#{concatenated_statuses}]\u001b[0m"
    statuses = line["lineStatuses"].map{ |status| LineStatus.new(status["statusSeverity"], status["statusSeverityDescription"]) }
    Line.new(line["name"], statuses)
  }.each do |l| 
    if l.is_good_service?
      puts "\u001b[32m\u2713\u001b[0m #{l.name}\t\u001b[32m[#{l.status}]\u001b[0m"
    else
      puts "\u001b[31m\u2717\u001b[0m #{l.name}\t\u001b[31m[#{l.status}]\u001b[0m"
    end
  end
end

