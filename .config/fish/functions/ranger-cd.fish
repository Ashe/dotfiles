#!/usr/bin/fish

# Allows the user to navigate using ranger
function ranger-cd                                                               
  set tempfile '/tmp/chosendir'                                                  
  /usr/bin/ranger --choosedir=$tempfile (pwd)                                    
  if test -f $tempfile                                                           
    if [ (cat $tempfile) != (pwd) ]                                            
      cd (cat $tempfile)                                                       
    end                                                                        
  end                                                                            
  rm -f $tempfile                                                                
end                                                                              
