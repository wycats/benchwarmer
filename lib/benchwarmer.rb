require "benchmark"
require File.join(File.expand_path(File.dirname(__FILE__)), "vendor", "dictionary")

module Enumerable
  def max_by(&blk)
    self.sort_by(&blk).last
  end
end

module Benchmark
  
  def self.warmer(times, &blk)
    Warmer.new(times).run(&blk)
  end
  
  class Warmer
    
    attr_reader :times, :columns, :groups
    def initialize(times)
      @times = times
    end
    
    def line!
      size = @name_max + @group_max + 1
      @columns.each do |name, val|
        size += (@columns[name].size <= 5 ? 5 : @columns[name].size) + 3
      end
      puts "-" * size
    end
    
    def blanks(size)
      print " " * size
    end
    
    def run(&blk)
      puts "Running the benchmarks #{@times} times each..."
      puts
      
      self.instance_eval(&blk)
      
      unless @columns
        @columns = Dictionary.new
        @columns[:results] = "Results"
      end
      
      @name_max = @groups.keys.max_by {|x| x.size}.size
      @group_max = @groups.values.map {|x| x.keys }.flatten.max_by {|x| x.size}.size
      
      print " " * (@name_max + @group_max + 2)
      
      puts @columns.map {|col,val| "%5s" % val }.join(" | ") + " |"

      line!

      @groups.each do |group_name,runs|
        # Print the group's name, left-justified and filling up as much space as the max
        # group name
        print "%-#{@name_max + 1}s" % group_name

        # Go through the registered runs
        runs.each_with_index do |(name, procs), i|
          blanks(@name_max + 1) if i > 0
          # The name has to take up all the space of the group name, and then some
          print "%#{@group_max}s" % name
          
          # Actually run the benchmarks
          procs.each_with_index do |proc, i|
            head = @columns[@columns.order[i]]
            bench = Benchmark.measure { @times.times(&proc)}
            print (" %#{head.size >= 5 ? head.size : 5}.2f |" % bench.real)
          end
          puts
        end
        
        line!
      end
    end
    
    def columns(*list)
      @columns = list.inject(Dictionary.new) do |accum, col|
        accum[col] = col.to_s.upcase
        accum
      end
    end
    
    def titles(titles)
      @columns.merge!(titles)
    end
    
    def group(str, &blk)
      @groups ||= Dictionary.new {|h,k| h[k] = Dictionary.new}
      @current_group = str
      self.instance_eval(&blk)
      @current_group = nil
    end
    
    def report(str, &blk)
      @groups ||= Dictionary.new
      if !@columns || @columns.size == 1
        @groups[@current_group || "default"][str] = [blk]
      else
        report = GroupReport.new(@columns.keys)
        report.instance_eval(&blk)
        @groups[@current_group || "default"][str] = report.runs
      end
    end
    
  end
  
  class GroupReport
    self.instance_methods.each do |meth|
      send(:undef_method, meth) unless meth =~ /^(__|instance_eval)/
    end
    
    attr_accessor :runs, :cols
    
    def initialize(cols)
      new_self = (class << self; self end)
      cols.each do |col|
        new_self.class_eval <<-RUBY
          def #{col}(&blk)
            @runs ||= []
            @runs << blk
          end
        RUBY
      end
    end
  end
  
end