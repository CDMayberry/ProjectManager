Pro = Struct.new(:start_date,:end_date)


#p = Array([Struct::Project.new(1,5),Struct::Project.new(6,7),Struct::Project.new(7,10),Struct::Project.new(15,18),Struct::Project.new(18,17)])

#duration = 5

#p.size()-2.times do |i| #-2 because of indexing
#    if (p[i+1].start_date - p[i].end_date) <= duration
#        puts "Next start: " + p[i+1].start_date.to_s
#        puts "Current end: " + p[i].end_date.to_s
#        puts "Gap: " + (p[i+1].start_date - p[i].end_date).to_s
#        puts "Works for index " + i.to_s
#    end
#end
