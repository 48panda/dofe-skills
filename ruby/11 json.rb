require 'json'

# Define constants

LINE = "┃"
BRANCH = "┣"
LAST = "┗"
ACROSS = "━"
GODOWN = "┓"

PAD_AMOUNT = 2 # The number of characters between each nesting level. 0 is none, it looks a bit wierd

LINEPAD = LINE + (" " * PAD_AMOUNT)
BRANCHPAD = BRANCH + (ACROSS * PAD_AMOUNT)
LASTPAD = LAST + (ACROSS * PAD_AMOUNT)
SPACEPAD = " " * (PAD_AMOUNT + 1)


def join_str_arrs(str_arr1, str_arr2)
    # Joins two arrays of strings
    # e.g. ["a", "b"] and ["c", "d"]
    # becomes ["ac", "bd"]
    out = []
    str_arr1.zip(str_arr2).each do |a, b|
        out.push(a + b)
    end
    out
end

def prettyprintarray(json_obj)
    size = json_obj.length
    output = []
    padding = []
    json_obj.each_with_index do |element, indx|
        out = prettyprint element
        current_out_size = output.length
        out.each {|x| output.push x}
        if indx == size - 1 then
            padding.push LASTPAD
            (out.length - 1).times do padding.push SPACEPAD end
        else
            padding.push BRANCHPAD
            (out.length - 1).times do padding.push LINEPAD end
        end
        output[current_out_size][0] = "┳" unless out.length == 1
    end
    join_str_arrs padding, output
end

def prettyprinthash(json_obj)
    size = json_obj.length
    output = []
    padding = []
    json_obj.each_with_index do |(k, v), indx|
        out = prettyprint v
        current_out_size = output.length
        if out.length == 1 then
            output.push "#{k}: #{out[0]}"
        else
            output.push k.to_s
            out.each {|x| output.push x}
        end
        if indx == size - 1 then
            padding.push LASTPAD
            (out.length).times do padding.push SPACEPAD end unless out.length == 1
        else
            padding.push BRANCHPAD
            (out.length).times do padding.push LINEPAD end unless out.length == 1
        end
    end
    join_str_arrs padding, output
end
    
def prettyprint(json_obj)
    return prettyprintarray json_obj if json_obj.is_a? Array
    return prettyprinthash json_obj if json_obj.is_a? Hash
    return [json_obj.inspect]
end

puts "Type the filename to display as json: "
filename = gets.chomp
file = File.new(filename, "r")

json = JSON.parse file.read

file.close

puts prettyprint json