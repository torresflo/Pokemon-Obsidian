#encoding: utf-8

#noyard
module PSP
  module_function
  def make_sprite(viewport = nil)
    @main_sprite = ::RPG::Sprite.new(viewport)
  end

  def dispose_sprite
    return unless @main_sprite
    @main_sprite.dispose
    @main_sprite = nil
  end

  def animation(src_sprite, id, reverse = false) # reverse = true if src_sprite = enemy
    (sp = @main_sprite).x = src_sprite.x# * $zoom_factor
    sp.y = src_sprite.y #* $zoom_factor
    sp.z = src_sprite.z
    sp.ox = src_sprite.ox
    sp.oy = src_sprite.oy
    sp.bitmap = src_sprite.bitmap
    sp.zoom_x = sp.zoom_y = src_sprite.zoom_x#$zoom_factor * src_sprite.zoom_x
    visible = src_sprite.visible
    src_sprite.visible = false
    animation = $data_animations[id]
    if animation
      sp.register_position
      sp.animation(animation, true, reverse)
      while sp.effect?
        sp.update
        sp.viewport.need_to_sort = true
        sp.viewport.sort_z
        Graphics.update
        Graphics.update if Graphics.frame_count % 3 == 0
      end
      sp.reset_position
      sp.update
      Graphics.update
    end
    sp&.viewport&.color&.set(0, 0, 0, 0) # Fix flash
    src_sprite.visible = visible
    sp.bitmap = nil
  end

  def move_animation(usr_sprite, trg_sprite, move_id, reverse = false)
    id = MOVE_TO_ID_ANIMATION_USER[move_id]
    animation(usr_sprite, id, reverse) if id
    id = MOVE_TO_ID_ANIMATION_TARGET[move_id]
    animation(trg_sprite, id, reverse) if id
  end

  MOVE_TO_ID_ANIMATION_TARGET = load_data("Data/PSP_MTAT.dat")
  MOVE_TO_ID_ANIMATION_USER = load_data("Data/PSP_MTAU.dat")
=begin
  MOVE_TO_ID_ANIMATION_TARGET = {
    468 => 470,
    469 => 720,
    470 => 716,
    471 => 735,
    472 => 679,
    473 => 686,
    474 => 687,
    475 => 734,
    476 => 712,
    477 => 725,
    478 => 680,
    479 => 696,
    480 => 751,
    481 => 739,
    482 => 730,
    483 => 731,
    484 => 675,
    485 => 749,
    486 => 676,
    487 => 747,
    488 => 684,
    489 => 708,
    490 => 752,
    491 => 674,
    492 => 754,
    493 => 738,
    494 => 761,
    495 => nil,
    496 => 682,
    497 => nil,
    498 => 732,
    499 => 697,
    500 => 711,
    501 => 717,
    502 => 681,
    503 => 700,
    504 => 678,
    505 => 759,
    506 => 685,
    507 => 688,
    508 => 705,
    509 => 713,
    510 => 721,
    511 => 741,
    512 => 669,
    513 => 727,
    514 => 757,
    515 => 760,
    516 => 718,
    517 => 722,
    518 => 743,
    519 => 744,
    520 => 745,
    521 => 692,
    522 => 748,
    523 => 673,
    524 => 746,
    525 => 699,
    526 => 740,
    527 => 704,
    528 => 703,
    529 => 755,
    530 => 698,
    531 => 693,
    532 => 706,
    533 => 709,
    534 => 724,
    535 => 690,
    536 => 691,
    537 => 742,
    538 => 715,
    539 => nil,
    540 => nil,
    541 => 733,
    542 => 758,
    543 => 683,
    544 => 707,
    545 => 736,
    546 => 750,
    547 => 729,
    548 => 723,
    549 => 728,
    550 => 714,
    551 => 710,
    552 => 753,
    553 => 737,
    554 => 689,
    555 => 668,
    556 => 719,
    557 => 756,
    558 => 694
  }
  #1.upto(467) do |i| MOVE_TO_ID_ANIMATION_TARGET[i] = i end
  1.upto(354) do |i| MOVE_TO_ID_ANIMATION_TARGET[i] = i end
  335.upto(467) do |i| MOVE_TO_ID_ANIMATION_TARGET[i] = i + 200 end
  MOVE_TO_ID_ANIMATION_USER = {
    555 => 426,
    512 => 440,
    495 => 672,
    484 => 440,
    540 => 677,
    543 => 428,
    488 => 429,
    535 => 440,
    559 => 695,
    530 => 440,
    525 => 440,
    497 => 701,
    539 => 702,
    528 => 430,
    532 => 440,
    544 => 440,
    533 => 440,
    550 => 431,
    548 => 440,
    534 => 440,
    498 => 432,
    545 => 433,
    537 => 440,
    487 => 440,
    522 => 434,
    485 => 435,
    490 => 440,
    492 => 436,
    529 => 440,
    557 => 440,
    514 => 437,
    515 => 438,
    462 => 440,
    460 => 425,
    459 => 424,
    458 => 440,
    457 => 440,
    453 => 653,
    450 => 440,
    448 => 648,
    445 => 645,
    442 => 400,
    440 => 440,
    438 => 440,
    436 => 636,
    435 => 423,
    434 => 400,
    431 => 440,
    429 => 422,
    428 => 421,
    421 => 440,
    418 => 440,
    416 => 440,
    413 => 613,
    410 => 440,
    409 => 440,
    407 => 440,
    405 => 605,
    404 => 440,
    403 => 440,
    401 => 440,
    399 => 599,
    398 => 440,
    395 => 440,
    394 => 419,
    393 => 593,
    1 => 440,
    2 => 440,
    3 => 440,
    4 => 440,
    5 => 440,
    7 => 440,
    8 => 440,
    9 => 440,
    10 => 440,
    11 => 440,
    12 => 440,
    15 => 440,
    20 => 440,
    21 => 440,
    22 => 440,
    23 => 440,
    24 => 440,
    25 => 440,
    26 => 440,
    27 => 440,
    28 => 440,
    29 => 440,
    30 => 440,
    31 => 440,
    32 => 440,
    33 => 440,
    34 => 440,
    35 => 440,
    36 => 440,
    37 => 440,
    38 => 440,
    39 => 39,
    43 => 43,
    64 => 440,
    65 => 440,
    66 => 440,
    67 => 440,
    68 => 440,
    70 => 440,
    98 => 440,
    99 => 392,
    117 => 440,
    125 => 440,
    128 => 440,
    130 => 440,
    132 => 440,
    136 => 440,
    146 => 440,
    150 => 150,
    152 => 440,
    153 => 153,
    154 => 440,
    155 => 440,
    158 => 440,
    162 => 440,
    163 => 440,
    165 => 393,
    166 => 440,
    167 => 440,
    168 => 440,
    172 => 394,
    175 => 395,
    177 => 177,
    179 => 396,
    180 => 180,
    183 => 440,
    185 => 440,
    198 => 440,
    205 => 440,
    206 => 440,
    214 => 214,
    216 => 397,
    220 => 220,
    224 => 440,
    228 => 440,
    229 => 399,
    231 => 400,
    232 => 400,
    233 => 401,
    237 => 237,
    238 => 440,
    244 => 244,
    245 => 440,
    249 => 440,
    252 => 440,
    253 => 253,
    255 => 255,
    263 => 402,
    264 => 440,
    265 => 440,
    269 => 269,
    274 => 440,
    276 => 403,
    277 => 277,
    279 => 404,
    280 => 440,
    283 => 440,
    284 => 405,
    290 => 406,
    292 => 440,
    298 => 298,
    299 => 440,
    302 => 440,
    303 => 440,
    305 => 440,
    306 => 440,
    309 => 440,
    310 => 440,
    311 => 408,
    313 => 313,
    315 => 315,
    321 => 409,
    323 => 410,
    325 => 411,
    326 => 412,
    327 => 440,
    332 => 440,
    337 => 440,
    340 => 440,
    342 => 440,
    344 => 413,
    348 => 440,
    351 => 351,
    354 => 414,
    356 => 415,
    357 => 557,
    358 => 440,
    359 => 440,
    360 => 416,
    363 => 563,
    364 => 440,
    365 => 440,
    368 => 568,
    369 => 569,
    370 => 440,
    371 => 417,
    372 => 440,
    375 => 418,
    376 => 440,
    378 => 440,
    381 => 581,
    383 => 583,
    386 => 440,
    389 => 440
  }
  MOVE_TO_ID_ANIMATION_USER.each do |id, ida|
    if id < 335 and id == ida
      MOVE_TO_ID_ANIMATION_TARGET[id] = nil
    elsif id >= 335 and id == (ida+200)
      MOVE_TO_ID_ANIMATION_TARGET[id] = nil
    end
  end
  MOVE_TO_ID_ANIMATION_TARGET.default = 1
  save_data(MOVE_TO_ID_ANIMATION_TARGET,"Data/PSP_MTAT.dat")
  save_data(MOVE_TO_ID_ANIMATION_USER,"Data/PSP_MTAU.dat")
=end
end
