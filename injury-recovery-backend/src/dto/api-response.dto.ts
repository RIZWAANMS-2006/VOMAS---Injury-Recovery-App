// src/dto/api-response.dto.ts
// Standard API response wrapper

/**
 * Standard error response structure
 */
export interface ApiError {
    code: string;
    message: string;
}

/**
 * Standard API response wrapper
 * All API responses follow this structure for consistency
 */
export class ApiResponseDto<T = unknown> {
    success: boolean;
    data?: T;
    error?: ApiError;

    private constructor(success: boolean, data?: T, error?: ApiError) {
        this.success = success;
        this.data = data;
        this.error = error;
    }

    /**
     * Create a successful response
     */
    static success<T>(data: T): ApiResponseDto<T> {
        return new ApiResponseDto(true, data, undefined);
    }

    /**
     * Create an error response
     */
    static error<T = undefined>(code: string, message: string): ApiResponseDto<T> {
        return new ApiResponseDto<T>(false, undefined, { code, message });
    }
}

// Common error codes
export const ErrorCodes = {
    INVALID_ACTION: 'INVALID_ACTION',
    VALIDATION_ERROR: 'VALIDATION_ERROR',
    NOT_FOUND: 'NOT_FOUND',
    INTERNAL_ERROR: 'INTERNAL_ERROR',
} as const;
