function lab = rgb2lab(rgb_im)

    if ~isa(rgb_im,'uint8'),
        rgb_im = im2uint8(rgb_im);
    end
    
    cform = makecform('srgb2lab');
    lab = applycform(rgb_im,cform);
    
end