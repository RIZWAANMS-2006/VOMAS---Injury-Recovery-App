// src/activities/activities.controller.ts
// REST controller for activities API

import {
    Controller,
    Get,
    Post,
    Body,
    HttpCode,
    HttpStatus,
    UsePipes,
    ValidationPipe,
} from '@nestjs/common';
import { ActivitiesService } from './activities.service';
import { CreateActivityDto } from '../dto/create-activity.dto';
import { ApiResponseDto, ErrorCodes } from '../dto/api-response.dto';
import { ActivityRecordDto } from '../dto/activity-record.dto';

/**
 * Controller for activity-related endpoints
 * All endpoints are prefixed with /api
 */
@Controller('api')
export class ActivitiesController {
    constructor(private readonly activitiesService: ActivitiesService) { }

    /**
     * POST /api/activities
     * Create a new activity from an action name
     */
    @Post('activities')
    @HttpCode(HttpStatus.CREATED)
    @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
    createActivity(
        @Body() createActivityDto: CreateActivityDto,
    ): ApiResponseDto<ActivityRecordDto | undefined> {
        const activity = this.activitiesService.createActivity(
            createActivityDto.actionName,
        );

        if (!activity) {
            // Return 400 for invalid action
            return ApiResponseDto.error(
                ErrorCodes.INVALID_ACTION,
                `Unsupported action name: "${createActivityDto.actionName}"`,
            );
        }

        return ApiResponseDto.success(activity);
    }

    /**
     * GET /api/activities
     * Get all activity history
     */
    @Get('activities')
    @HttpCode(HttpStatus.OK)
    getActivities(): ApiResponseDto<ActivityRecordDto[]> {
        const activities = this.activitiesService.findAll();
        return ApiResponseDto.success(activities);
    }

    /**
     * GET /api/actions
     * Get the action → measurement mapping
     */
    @Get('actions')
    @HttpCode(HttpStatus.OK)
    getActionMappings(): ApiResponseDto<
        Record<string, { shoulder: string; elbow: string; wrist: string }>
    > {
        const mappings = this.activitiesService.getActionMappings();
        return ApiResponseDto.success(mappings);
    }
}
