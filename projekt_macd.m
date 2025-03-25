save data.mat gmeusd nvdausd
%%
load data.mat gmeusd nvdausd
%%

hold on
%plot(gmeusd.date, gmeusd.closingPrice)
%plot(nvdausd.date, nvdausd.closingPrice, "k")
%ylabel("cena zamknięcia 1 akcji");
%xlabel("data");
%title("Wykres ceny akcji NVidia Corp od czasu");
%print -dpng wykres_nvdausd.png
%hold off


actions = [1000, 1000];
money = [0, 0];

nvidia_macd = macd(nvdausd.closingPrice);
nvidia_signal = signal(nvidia_macd);

gamestop_macd = macd(gmeusd.closingPrice);
gamestop_signal = signal(gamestop_macd);


%plot(gmeusd.date, nvidia_macd, "b")
%plot(gmeusd.date, nvidia_signal, "r")

%plot(gmeusd.date, gamestop_macd, "b")
%plot(gmeusd.date, gamestop_signal, "r")

%xlabel("date")
%ylabel("price")
%title("Wykres ceny od czasu, z nałożeniem linii MACD i signal oraz punktów sprzedaży")


[actions(1), money(1)] = invest(gamestop_macd, gamestop_signal, gmeusd.closingPrice, 1, actions, money, gmeusd.date)
%[actions(1), money(1)] = invest(nvidia_macd, nvidia_signal, nvdausd.closingPrice, 2, actions, money, nvdausd.date)
legend("kup i zapomnij", "algorytm MACD")
title("Wykres wartości portfolio od czasu dla akcji NVidii")
%legend("NVidia cena", "NVidia macd", "NVidia signal",  "sygnał sprzedarzy","sygnał kupna");
hold off

function [result_actions, result_money] = invest(macd, signal, cvs, capital_num, start_actions, start_money, date_info)
actions = start_actions(capital_num);
money = start_money(capital_num);
mac_lower = 0;
last_mac = 0;
sum_money = zeros(size(cvs, 1), 1);
    for i = 36:size(cvs,1)
        if macd(i) > signal(i)
            mac_lower = 0;
        else
            mac_lower = 1;
        end

        if mac_lower ~= last_mac
            if mac_lower > last_mac
                money = money + actions * cvs(i);
                actions = 0;
                %plot([date_info(i), date_info(i)], [min(macd), max(cvs)], "g--")
            else
                while money > cvs(i)
                    money = money - cvs(i);
                    actions = actions + 1;
                end
                %plot([date_info(i), date_info(i)], [min(macd), max(cvs)], "r--")
            end
        end
        last_mac = mac_lower;
        sum_money(i) = money + actions * cvs(i);
    end

    if actions == 0
        while money > cvs(end)
            money = money - cvs(end);
            actions = actions + 1;
        end
    end

    if actions ~= 0
       money = money + actions * cvs(end);
        actions = 0;
    end
    
    plot(date_info, cvs * 1000, "r")
    plot(date_info, sum_money, "k")

    result_actions = actions;
    result_money = money;
end

function result = signal(cvs)
    result = zeros(size(cvs, 1), 1);
    for i = 35:size(result,1)
        result(i) = ema(cvs, 9, i);
    end
    %result = flipud(result)
end

function result = macd(cvs)
    result = zeros(size(cvs, 1), 1);
    for i = size(result,1):-1:26
        result(i) = ema(cvs, 12, i) - ema(cvs, 26, i);
    end
    %result = flipud(result)
end

function result = ema(cvs, n, offset)
result = cvs(offset);
divider = 1;
    for i = 2:n
        result = result + ((1 - (2 / (n + 1))) ^ i) * cvs(offset - i + 1);
        divider = divider + ((1 - (2 / (n + 1))) ^ i);
    end
result = result / divider;
end