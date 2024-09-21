classdef Intersections < utils.class.Container
    properties
        Config;
        Network;
        Roads;
    end

    properties
        Elements;
    end

    methods
        function obj = Intersections(Network)
            % Configクラスを設定
            obj.Config = Network.get('Config');

            % Networkクラスを設定
            obj.Network = Network;

            % 要素クラスを作成
            obj.create('Elements');
        end
    end

    methods
        create(obj, property_name);
    end
end