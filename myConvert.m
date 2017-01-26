

function [allOneString] = myConvert(n)
    allOneString = sprintf('%.0f, ' , n);
    allOneString = allOneString(1:end-2);
end