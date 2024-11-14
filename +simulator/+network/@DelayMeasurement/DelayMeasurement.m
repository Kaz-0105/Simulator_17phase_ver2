classdef DelayMeasurement < utils.class.Common
    properties
        Config;
        DelayMeasurements;
        Link;
        FromLink;
        ToLink;
        FromRoad;
        ToRoad;
    end

    properties
        id;
        Vissim;
    end

    methods
        function obj = DelayMeasurement(DelayMeasurements, id)
            % ConfigクラスとDelayMeasurementsクラスを設定
            obj.Config = DelayMeasurements.get('Config');
            obj.DelayMeasurements = DelayMeasurements;

            % idを設定
            obj.id = id;

            % DelayMeasurementのCOMオブジェクトを設定
            obj.create('Vissim');

            % Linkクラス関連の設定
            obj.create('Links');

            % Roadクラス関連の設定
            obj.create('Roads');
        end
    end

    methods
        create(obj, property_name);
    end
end