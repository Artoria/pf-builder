class Builder
  def initialize(&block)
    @str = "%s"
    @first = false
    instance_exec &block
  end

  def push_replace(x)
     @str = @str.gsub("%s"){
        "((%s) .) . #{x}"
     }
  end

 def modify_replace(x)
     @str = @str.gsub("%s"){
        "(%s) . #{x}"
     }
  end

  def finish!
    "((" + @str.gsub("((%s) .) . ", " fst .").gsub("(%s) .", " fst .") + ") undefined)"
  end

  def push_arg
    push_replace "flip (,)"
  end

  def apply
    modify_replace "(uncurry ($) . (first *** id))"
  end

  def modify(x)
    modify_replace "(first (#{x}))"
  end

  def modify_dup(x)
    vdup
    modify_replace "(first (#{x}))"
  end

  def op(arity)
    push_arg
    arity.times { apply }
  end
  
  def push_const(x)
    modify_replace "((,) (#{x}))"
  end

  def vdup
   # (a, b) -> (a, (a, b))
   modify_replace "(fst >>= (,))"
  end

  def  vpop
   #(a, b) -> b
    modify_replace "snd"
  end

  def vswap
    # (a, (b, c)) -> (b, (a, c))
    modify_replace "((fst . snd) &&& (fst &&& (snd . snd)))"
  end

  def vover
    #  (a, (b, c)) -> (b, (a, (b, c)))
    modify_replace "((fst . snd) &&& id)"
  end
end
