classdef Link < utils.class.Common
    properties
        Config;
        Links;
    end

    properties
        id;
        type;
        length;
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
        end
    end

    methods
        create(obj, property_name);
    end
end