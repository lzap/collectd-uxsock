require 'socket'

module Uxsock
  class CollectdUnixSock
    DEFAULT_SOCKET = '/var/run/collectd-unixsock'

    attr_reader :path, :verbose
    alias_method :verbose?, :verbose

    def initialize(path = DEFAULT_SOCKET, verbose = false)
      @path = path
      @socket = UNIXSocket.open(@path)
      @verbose = verbose
    end

    def close
      @socket.close unless @socket.nil?
      @socket = nil
    end

    def self.open(path = DEFAULT_SOCKET, verbose = false)
      socket = self.new(path, verbose)
      yield(socket)
    ensure
      socket.close unless socket.nil?
    end

    def listval
      cmd("LISTVAL")
    end

    def each_value
      n_lines = listval
      n_lines.times do
        line = readline
        time_s, identifier = line.split(' ', 2)
        time = Time.at(time_s.to_i)
        yield time, identifier
      end
    end

    def getval id
      cmd("GETVAL \"#{id}\"")
    end

    def each_value_data(id)
      n_lines = getval(id)
      n_lines.times do
        line = readline
        col, val = line.split('=', 2)
        yield col, val
      end
    end

    def putval id, value_list, interval = nil
      interval = "interval=#{interval}" if interval
      if value_list.is_a?(Array)
        filtered_values = value_list.map { |n| ruby2value(n) }.join(':')
      else
        filtered_values = ruby2value(value_list)
      end
      cmd("PUTVAL \"#{id}\" #{interval} N:#{filtered_values}")
    end

    def putnotif message, time = Time.now.utc, severity = 'okay', host = nil, options = {}
      host = "host=#{host}" if host
      opts = options.map { |k, v| "#{k.to_s}=#{v}" }.join(' ')
      cmd("PUTNOTIF time=#{time.to_i} severity=#{severity.to_s} #{host} #{opts} message=\"#{message}\"")
    end

    private

    def writeline line
      puts "> #{line}\n" if verbose?
      @socket.write("#{line}\n")
    end

    def readline
      line = @socket.readline.chomp
      puts "< #{line}" if verbose?
      line
    end

    def cmd(c)
      writeline(c)
      status_string, message = readline.split(' ', 2)
      status = status_string.to_i rescue -1
      raise message if status < 0
      status
    end

    def ruby2value n
      (n.is_a?(Float) && (n.infinite? == 1 || n.nan? == 1)) ? 'U' : n
    end
  end

  if __FILE__ == $0
    hostname = Socket.gethostname
    Uxsock::CollectdUnixSock.open do |socket|
      socket.instance_variable_set(:@verbose, true)

      socket.each_value do |time, id|
        ids = id.split('/')
        name = ids[0]
        local_ids = ids[1..-1].join('/')
        puts "#{time}: (#{name}) #{local_ids}"
      end

      socket.each_value_data("#{hostname}/load/load") do |col, val|
        puts "#{col}: #{val}\n"
      end

      socket.putnotif "Hello collectd!"
      socket.putval "#{hostname}/example/counter", 2
      socket.putval "#{hostname}/infinity/count", 1.0 / 0.0
    end
  end
end
