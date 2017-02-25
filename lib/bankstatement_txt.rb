#!/usr/bin/env ruby

# file: bankstatement_txt.rb

require 'csv'
require 'pxlite'
require 'dynarex'


class BankStatementTxt
  
  attr_reader :px

  def initialize()
  end

  def import(filepath)

    new_import(filepath)
    
  end
  
  def inspect()
    "<bankstatement #{object.id}>"
  end
  
  def summary()    
    @dx
  end
  

  private

  def new_import(filepath)


    data = File.read filepath
    csv = CSV.new(data, :headers => true, :header_converters => :symbol, 
                  :converters => :all)
    a = csv.to_a.map(&:to_hash)

    a.reject!(&:empty?)
    a2 = a.group_by {|x| Date.parse(x[:date]).year }

    a3 = a2.inject({}) do |r, pair| 

      year, x = pair      
      r.merge(year => x.group_by {|y| Date.parse(y[:date]).month})
      
    end

    px = PxLite.new("statement[title,tags]/year[title]/month[title, " + 
                     "credit, debit]/entry[date, type, desc, credit, " + 
                     "debit, balance, tags]")    
    
    rec = []

    a3.each do |year, year_entries|
      
      rec << yearx = [{title: year.to_s}, []]

      year_entries.each do |month, entries|

        yearx.last << monthx = [{title: Date::ABBR_MONTHNAMES[month]}, []]

        entries.each do |x|

          v = x[:value]
          credit, debit = v > 0 ? [v, nil] : [nil, v.abs]
          monthx.last << [{date: x[:date], type: x[:type], 
                        desc: x[:description], credit: credit, 
                        debit: debit, balance: x[:balance]}, []]
        end

      end

    end
    
    # totalise each the credit and debit columns for each month
    
    rec.each do |year, months|
      months.each do |month, entries|
        month[:credit] = entries.map {|x| x[0][:credit].to_f }.inject(:+)
        month[:debit] =  entries.map {|x| x[0][:debit].to_f }.inject(:+)
      end
    end
    
    
    # create a Dynarex document for the totals for each month
    
    @dx = Dynarex.new('months[title]/month(uid, year, month, ' + 
                      'debit, credit, net_income)')

    rec.each do |year, months|
      
      months.each do |month, entries|

        debit, credit = month[:debit], month[:credit]
        
        @dx.create year: year[:title], month: month[:title], 
          debit: debit.round(2), credit: credit.round(2), 
          net_income: (credit - debit).round(2)

      end
      
    end    
    
    
    px.records = rec

    @px = px 
    
  end

end