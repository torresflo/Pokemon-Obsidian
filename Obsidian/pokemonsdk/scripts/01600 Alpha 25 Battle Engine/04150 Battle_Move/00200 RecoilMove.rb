module Battle
  # Move that has a little recoil when it hits the opponent
  class RecoilMove < Move
    def recoil?
      true
    end
  end

  Move.register(:s_recoil, RecoilMove)
end
