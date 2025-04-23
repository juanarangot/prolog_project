% --------------------------------------------
% PARTE 1: Catalogo de vehiculos
% --------------------------------------------
% vehicle(Brand, Model, Type, Price, Year)
vehicle(toyota, rav4, suv, 28000, 2022).
vehicle(toyota, highlander, suv, 20600, 2024).
vehicle(toyota, land_cruiser, suv, 85000, 2025).
vehicle(toyota, corolla, sedan, 15000, 2023).
vehicle(toyota, tacoma, pickup, 35000, 2021).
vehicle(ford, mustang, sport, 40000, 2023).
vehicle(ford, explorer, suv, 38000, 2022).
vehicle(ford, f150, pickup, 42000, 2023).
vehicle(kia, sorento, suv, 35000, 2022).
vehicle(kia, forte, sedan, 20000, 2024).
vehicle(bmw, x5, suv, 60000, 2021).
vehicle(bmw, serie3, sedan, 41000, 2022).
vehicle(audi, q7, suv, 52000, 2021).
vehicle(audi, a3, sedan, 45000, 2023).
vehicle(honda, civic, sedan, 24000, 2023).
vehicle(nissan, sentra, sedan, 23000, 2022).
vehicle(mazda, cx5, suv, 29000, 2023).

% --------------------------------------------
% PARTE 2: Consultas basicas y filtros
% --------------------------------------------
% Filtro por presupuesto
meet_budget(Reference, BudgetMax) :-
    vehicle(_, Reference, _, Price, _),
    Price =< BudgetMax.

% Listar vehiculos por marca
vehicles_by_brand(Brand, Vehicles) :-
    findall(Reference, vehicle(Brand, Reference, _, _, _), Vehicles).

% --------------------------------------------
% PARTE 3: Generacion de reportes
% --------------------------------------------
% Predicado principal para generar reportes
generate_report(Brand, Type, Budget, TotalLimit, Result) :-
    % 1. Obtener vehiculos que cumplen con Brand, Type y Budget
    findall(vehicle(Brand, Model, Type, Price, Year),
            (vehicle(Brand, Model, Type, Price, Year), Price =< Budget),
            Filtered),

    % 2. Ordenar por precio ascendente
    sort_by_price(Filtered, Sorted),

    % 3. Calcular total y ajustar si supera el limite
    calculate_total(Sorted, Total),
    (Total =< TotalLimit
        -> Result = [vehicles:Sorted, total:Total]
        ;  adjust_to_limit(Sorted, TotalLimit, AdjustedVehicles, AdjustedTotal),
           Result = [vehicles:AdjustedVehicles, total:AdjustedTotal]
    ).

% Helper: Ordenar vehiculos por precio
sort_by_price(Vehicles, Sorted) :-
    predsort(compare_by_price, Vehicles, Sorted).

compare_by_price(Order, vehicle(_, _, _, P1, _), vehicle(_, _, _, P2, _)) :-
    compare(Order, P1, P2).

% Helper: Calcular precio total
calculate_total([], 0).
calculate_total([vehicle(_, _, _, P, _)|T], Total) :-
    calculate_total(T, Rest),
    Total is P + Rest.

% Helper: Ajustar al limite total
adjust_to_limit(Vehicles, Limit, Result, Total) :-
    adjust_to_limit(Vehicles, Limit, [], 0, Result, Total).

adjust_to_limit([], _, Acc, Total, Acc, Total).
adjust_to_limit([V|Rest], Limit, CurrentAcc, CurrentTotal, FinalAcc, FinalTotal) :-
    vehicle(_, _, _, Price, _) = V,
    NewTotal is CurrentTotal + Price,
    (NewTotal =< Limit
        -> append(CurrentAcc, [V], NewAcc),
           adjust_to_limit(Rest, Limit, NewAcc, NewTotal, FinalAcc, FinalTotal)
        ;  FinalAcc = CurrentAcc,
           FinalTotal = CurrentTotal
    ).

% Predicado para listar vehiculos en texto plano
list_vehicles :-
    write('Listado completo de vehiculos:'), nl, nl,
    forall(
        vehicle(Brand, Model, Type, Price, Year),
        format('Marca: ~w | Modelo: ~w | Tipo: ~w | Precio: $~d | Año: ~d~n',
              [Brand, Model, Type, Price, Year])
    ),
    count_vehicles(Total),
    nl, format('Total de vehiculos registrados: ~d', [Total]).

% Mantener el contador
count_vehicles(Total) :-
    findall(_, vehicle(_, _, _, _, _), Vehicles),
    length(Vehicles, Total).

% Predicado para mostrar todos los vehiculos con formato

% --------------------------------------------
% PARTE 4: Casos de prueba
% --------------------------------------------

% probar las funciones
% meet_budget(land_cruiser, 90000).
% meet_budget(Referencia, 20000).
% vehicles_by_brand(toyota, Vehicles).


% Caso 1: Toyota SUV < $30k
% ?- findall(Ref, (vehicle(toyota, Ref, suv, Price, _), Price < 30000), Result).
% Result = [rav4, highlander]

% Caso 2: Ford agrupados por tipo y año
% ?- bagof((Type, Year, Ref), vehicle(ford, Ref, Type, _, Year), Groups).
% Groups = [(pickup, 2023, f150), (sport, 2023, mustang), (suv, 2022, explorer)]

% Caso 3: Total de sedanes <= $500k
% ?- generate_report(_, sedan, 1000000, 500000, Result).
% Result = [vehicles:[...], total:168000]
