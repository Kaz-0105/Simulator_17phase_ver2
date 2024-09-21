classdef Roads < utils.class.Container
    properties
        Config;
    end

    properties
        Elements;
    end

    methods
        function obj = Roads(Network_or_Intersection, type)
            % Configクラスを設定
            obj.Config = Network_or_Intersection.get('Config');

            % typeによって分岐
            if isa(Network_or_Intersection, 'simulator.Network')
                % プロパティにNetworkクラスを追加
                prop = addprop(obj, 'Network');
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';

                % Networkクラスを設定
                obj.Network = Network_or_Intersection;

                % プロパティにIntersectionsクラスを追加
                prop = addprop(obj, 'Intersections');
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';

                % Intersectionsクラスを設定
                obj.Intersections = obj.Network.get('Intersections');
                obj.Intersections.set('Roads', obj);

                % 要素クラスを作成
                obj.create('Elements', 'Network');

                % 要素クラスにVissimのSignalHeadオブジェクトをセット
                obj.create('SignalHeads');
            elseif isa(Network_or_Intersection, 'simulator.network.Intersection')
                % プロパティにIntersectionsクラスを追加
                prop = addprop(obj, 'Intersection');
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';

                % Intersectionsクラスを設定
                obj.Intersection = Network_or_Intersection;

                % プロパティにtypeを追加
                prop = addprop(obj, 'type');
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';

                % typeを設定
                obj.type = type;

                % 要素クラスを作成
                obj.create('Elements', 'Intersection');
            else
                error('error: invalid argument');
            end
        end
    end

    methods
        create(obj, property_name, type);
        update(obj, property_name);
    end
end