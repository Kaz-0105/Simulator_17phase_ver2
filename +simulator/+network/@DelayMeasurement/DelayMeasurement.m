classdef DelayMeasurement < utils.class.Common
    properties
        Config;
        DelayMeasurements;
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
        end
    end
end