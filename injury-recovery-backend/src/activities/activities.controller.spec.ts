// src/activities/activities.controller.spec.ts
// Unit tests for ActivitiesController

import { Test, TestingModule } from '@nestjs/testing';
import { ActivitiesController } from './activities.controller';
import { ActivitiesService } from './activities.service';
import { ErrorCodes } from '../dto/api-response.dto';

describe('ActivitiesController', () => {
    let controller: ActivitiesController;
    let service: ActivitiesService;

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            controllers: [ActivitiesController],
            providers: [ActivitiesService],
        }).compile();

        controller = module.get<ActivitiesController>(ActivitiesController);
        service = module.get<ActivitiesService>(ActivitiesService);

        // Clear activities before each test
        service.clearActivities();
    });

    describe('POST /api/activities', () => {
        it('should create an activity for valid action', () => {
            const result = controller.createActivity({
                actionName: 'Flexion / Extension',
            });

            expect(result.success).toBe(true);
            expect(result.data).toBeDefined();
            expect(result.data?.actionName).toBe('Flexion / Extension');
            expect(result.data?.measurements).toEqual({
                shoulder: 'Roll',
                elbow: 'Roll',
                wrist: 'Pitch',
            });
            expect(result.data?.id).toBeDefined();
            expect(result.data?.timestamp).toBeDefined();
        });

        it('should return error for invalid action', () => {
            const result = controller.createActivity({
                actionName: 'Invalid Action',
            });

            expect(result.success).toBe(false);
            expect(result.error).toBeDefined();
            expect(result.error?.code).toBe(ErrorCodes.INVALID_ACTION);
        });

        it('should create activities for all valid actions', () => {
            const validActions = [
                'Flexion / Extension',
                'Abduction',
                'Internal / External Rotation',
                'Horizontal Abduction / Adduction',
                'Forearm Pronation / Supination',
                'Radial / Ulnar Deviation',
            ];

            validActions.forEach((actionName) => {
                const result = controller.createActivity({ actionName });
                expect(result.success).toBe(true);
                expect(result.data?.actionName).toBe(actionName);
            });
        });
    });

    describe('GET /api/activities', () => {
        it('should return empty array when no activities exist', () => {
            const result = controller.getActivities();

            expect(result.success).toBe(true);
            expect(result.data).toEqual([]);
        });

        it('should return all created activities', () => {
            // Create some activities
            controller.createActivity({ actionName: 'Flexion / Extension' });
            controller.createActivity({ actionName: 'Abduction' });

            const result = controller.getActivities();

            expect(result.success).toBe(true);
            expect(result.data?.length).toBe(2);
        });

        it('should return activities in most recent first order', () => {
            controller.createActivity({ actionName: 'Flexion / Extension' });
            controller.createActivity({ actionName: 'Abduction' });

            const result = controller.getActivities();

            expect(result.success).toBe(true);
            // Most recent should be first
            expect(result.data?.[0].actionName).toBe('Abduction');
            expect(result.data?.[1].actionName).toBe('Flexion / Extension');
        });
    });

    describe('GET /api/actions', () => {
        it('should return all action mappings', () => {
            const result = controller.getActionMappings();

            expect(result.success).toBe(true);
            expect(result.data).toBeDefined();

            // Check specific mappings
            expect(result.data?.['Flexion / Extension']).toEqual({
                shoulder: 'Roll',
                elbow: 'Roll',
                wrist: 'Pitch',
            });

            expect(result.data?.['Internal / External Rotation']).toEqual({
                shoulder: 'Pitch',
                elbow: 'Roll',
                wrist: 'Pitch',
            });

            expect(result.data?.['Horizontal Abduction / Adduction']).toEqual({
                shoulder: 'Yaw',
                elbow: 'Yaw',
                wrist: 'Pitch',
            });
        });

        it('should return all 6 action mappings', () => {
            const result = controller.getActionMappings();

            expect(result.success).toBe(true);
            expect(Object.keys(result.data || {}).length).toBe(6);
        });
    });
});
