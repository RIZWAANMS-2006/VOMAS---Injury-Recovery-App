// src/dto/create-activity.dto.ts
// DTO for creating a new activity

import { IsString, IsNotEmpty } from 'class-validator';

/**
 * DTO for creating a new activity
 * Only requires the action name - measurements are derived by backend
 */
export class CreateActivityDto {
    @IsString()
    @IsNotEmpty({ message: 'Action name is required' })
    actionName: string;
}
