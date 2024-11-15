classdef Link < utils.class.Common
    properties
        Config;
        Timer;
        Links;
        Road;
    end

    properties
        id;
        class;
        length;
        num_lanes;
        Vissim;
    end

    methods
        function obj = Link(Links, id)
            % ConfigクラスとTimerクラスとLinksクラスを設定
            obj.Config = Links.get('Config');
            obj.Timer = Links.get('Timer');
            obj.Links = Links;

            % LinkのIDを取得
            obj.id = id;

            % VissimのComオブジェクトを取得
            obj.create('Vissim');

            % lengthの設定
            obj.length = obj.Vissim.get('AttValue', 'Length2D');

            % num_lanesの設定
            obj.num_lanes = obj.Vissim.Lanes.Count();
        end
    end

    methods
        create(obj, property_name);
    end
end