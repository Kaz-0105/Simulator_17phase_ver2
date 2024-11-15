classdef Controller < utils.class.Common
    properties
        Config;
        Timer;
        Controllers;
    end

    properties
        id;
    end

    methods 
        function obj = Controller(Controllers, id, UpperClass)
            % Configクラス、Timerクラス、Controllersクラスを取得
            obj.Config = Controllers.get('Config');
            obj.Timer = Controllers.get('Timer');
            obj.Controllers = Controllers;

            % idを設定
            obj.id = id;

            % UpperClassによって分岐
            if isa(UpperClass, 'simulator.network.Intersection')
                % Intersectionクラスを設定
                obj.set('Intersection' ,UpperClass);
                obj.Intersection.set('Controller', obj);

                % 制御手法の設定
                obj.create('Method');
            else
                error('UpperClass is invalid');
            end
        end
    end

    methods
        create(obj, property_name);
        run(obj);
    end
end