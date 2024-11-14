classdef Link < utils.class.Common
    properties
        Config;
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
            % ConfigクラスとLinksクラスを取得
            obj.Config = Links.get('Config');
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